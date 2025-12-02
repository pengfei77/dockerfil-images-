package controller

import (
	"context"
	"fmt"
	"time"

	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/util/runtime"
	"k8s.io/apimachinery/pkg/util/wait"
	"k8s.io/client-go/informers"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/cache"
	"k8s.io/client-go/util/workqueue"

	"k8s-secrets-controller/pkg/config"
	"k8s-secrets-controller/pkg/k8s"
	"k8s-secrets-controller/pkg/logger"
	"k8s-secrets-controller/pkg/metrics"
)

// Controller Kubernetes控制器
type Controller struct {
	clientset     *kubernetes.Clientset
	config        *config.Config
	logger        logger.Logger
	metrics       *metrics.Metrics
	
	namespaceInformer cache.SharedIndexInformer
	workqueue        workqueue.RateLimitingInterface
	
	ctx    context.Context
	cancel context.CancelFunc
}

// NewController 创建新的控制器
func NewController(cfg *config.Config, logger logger.Logger, metrics *metrics.Metrics) (*Controller, error) {
	// 创建Kubernetes客户端
	k8sClient, err := k8s.NewClient()
	if err != nil {
		return nil, fmt.Errorf("创建Kubernetes客户端失败: %v", err)
	}
	
	clientset := k8sClient.GetClientset()
	
	// 创建上下文
	ctx, cancel := context.WithCancel(context.Background())
	
	controller := &Controller{
		clientset: clientset,
		config:    cfg,
		logger:    logger,
		metrics:   metrics,
		workqueue: workqueue.NewNamedRateLimitingQueue(
			workqueue.DefaultControllerRateLimiter(),
			"Namespaces",
		),
		ctx:    ctx,
		cancel: cancel,
	}
	
	// 创建Namespace Informer
	factory := informers.NewSharedInformerFactory(clientset, time.Duration(cfg.ResyncPeriod)*time.Second)
	controller.namespaceInformer = factory.Core().V1().Namespaces().Informer()
	
	// 注册事件处理器
	controller.namespaceInformer.AddEventHandler(cache.ResourceEventHandlerFuncs{
		AddFunc: controller.handleNamespaceAdd,
		UpdateFunc: controller.handleNamespaceUpdate,
		DeleteFunc: controller.handleNamespaceDelete,
	})
	
	return controller, nil
}

// Run 启动控制器
func (c *Controller) Run(threadiness int) error {
	defer runtime.HandleCrash()
	defer c.workqueue.ShutDown()
	
	c.logger.Info("启动Kubernetes Secrets控制器")
	
	// 启动Informer
	go c.namespaceInformer.Run(c.ctx.Done())
	
	// 等待缓存同步
	if !cache.WaitForCacheSync(c.ctx.Done(), c.namespaceInformer.HasSynced) {
		return fmt.Errorf("等待缓存同步超时")
	}
	
	c.logger.Info("缓存同步完成，启动工作器")
	
	// 启动工作器
	for i := 0; i < threadiness; i++ {
		go wait.Until(c.runWorker, time.Second, c.ctx.Done())
	}
	
	c.logger.Info("控制器已启动")
	
	// 等待停止信号
	<-c.ctx.Done()
	c.logger.Info("控制器已停止")
	
	return nil
}

// Stop 停止控制器
func (c *Controller) Stop() {
	c.cancel()
}

// runWorker 运行工作器
func (c *Controller) runWorker() {
	for c.processNextItem() {
	}
}

// processNextItem 处理下一个队列项
func (c *Controller) processNextItem() bool {
	obj, shutdown := c.workqueue.Get()
	if shutdown {
		return false
	}
	
	// 确保处理完成后从队列中删除
	defer c.workqueue.Done(obj)
	
	key, ok := obj.(string)
	if !ok {
		c.workqueue.Forget(obj)
		c.logger.Errorf("队列项不是字符串: %#v", obj)
		return true
	}
	
	// 处理命名空间
	err := c.processNamespace(key)
	if err != nil {
		c.handleError(key, err)
	}
	
	return true
}

// processNamespace 处理命名空间
func (c *Controller) processNamespace(key string) error {
	startTime := time.Now()
	
	// 从缓存中获取命名空间对象
	obj, exists, err := c.namespaceInformer.GetIndexer().GetByKey(key)
	if err != nil {
		return fmt.Errorf("从缓存获取命名空间失败: %v", err)
	}
	
	if !exists {
		c.logger.Debugf("命名空间已删除: %s", key)
		return nil
	}
	
	namespace := obj.(*corev1.Namespace)
	
	// 检查是否应该排除该命名空间
	if c.config.IsExcludedNamespace(namespace.Name) {
		c.logger.Debugf("跳过系统命名空间: %s", namespace.Name)
		return nil
	}
	
	c.logger.Infof("处理命名空间: %s", namespace.Name)
	
	// 检查Secret是否已存在
	exists, err = c.checkSecretExists(namespace.Name)
	if err != nil {
		return fmt.Errorf("检查Secret存在性失败: %v", err)
	}
	
	if exists {
		c.logger.Debugf("Secret已存在，跳过创建: %s", namespace.Name)
		return nil
	}
	
	// 创建TLS Secret
	err = c.createTLSSecret(namespace.Name)
	if err != nil {
		return fmt.Errorf("创建TLS Secret失败: %v", err)
	}
	
	// 记录指标
	duration := time.Since(startTime)
	c.metrics.RecordOperationDuration("create_secret", namespace.Name, duration)
	c.metrics.RecordSecretCreated(namespace.Name, c.config.SecretName)
	
	c.logger.Infof("成功为命名空间创建TLS Secret: %s", namespace.Name)
	
	return nil
}

// handleNamespaceAdd 处理命名空间添加事件
func (c *Controller) handleNamespaceAdd(obj interface{}) {
	namespace := obj.(*corev1.Namespace)
	
	// 记录指标
	c.metrics.RecordNamespaceCreated(namespace.Name)
	
	// 添加到工作队列
	key, err := cache.MetaNamespaceKeyFunc(obj)
	if err != nil {
		c.logger.Errorf("获取命名空间键失败: %v", err)
		return
	}
	
	c.workqueue.Add(key)
	c.logger.Debugf("命名空间添加事件已入队: %s", namespace.Name)
}

// handleNamespaceUpdate 处理命名空间更新事件
func (c *Controller) handleNamespaceUpdate(oldObj, newObj interface{}) {
	oldNamespace := oldObj.(*corev1.Namespace)
	newNamespace := newObj.(*corev1.Namespace)
	
	// 如果命名空间状态没有变化，跳过处理
	if oldNamespace.Status.Phase == newNamespace.Status.Phase {
		return
	}
	
	// 记录指标
	c.metrics.RecordNamespaceCreated(newNamespace.Name)
	
	// 添加到工作队列
	key, err := cache.MetaNamespaceKeyFunc(newObj)
	if err != nil {
		c.logger.Errorf("获取命名空间键失败: %v", err)
		return
	}
	
	c.workqueue.Add(key)
	c.logger.Debugf("命名空间更新事件已入队: %s", newNamespace.Name)
}

// handleNamespaceDelete 处理命名空间删除事件
func (c *Controller) handleNamespaceDelete(obj interface{}) {
	namespace := obj.(*corev1.Namespace)
	
	c.logger.Infof("命名空间已删除: %s", namespace.Name)
	
	// 更新指标
	c.metrics.SetTotalNamespaces(c.getTotalNamespaces() - 1)
}

// checkSecretExists 检查Secret是否存在
func (c *Controller) checkSecretExists(namespace string) (bool, error) {
	_, err := c.clientset.CoreV1().Secrets(namespace).Get(c.ctx, c.config.SecretName, metav1.GetOptions{})
	if err != nil {
		if errors.IsNotFound(err) {
			return false, nil
		}
		return false, err
	}
	return true, nil
}

// createTLSSecret 创建TLS Secret
func (c *Controller) createTLSSecret(namespace string) error {
	// 读取证书文件
	certData, keyData, err := c.config.GetCertificateData()
	if err != nil {
		c.metrics.RecordSecretError(namespace, "certificate_read_error")
		return fmt.Errorf("读取证书文件失败: %v", err)
	}
	
	// 创建Secret
	secret := &corev1.Secret{
		ObjectMeta: metav1.ObjectMeta{
			Name:      c.config.SecretName,
			Namespace: namespace,
		},
		Type: corev1.SecretTypeTLS,
		Data: map[string][]byte{
			"tls.crt": certData,
			"tls.key": keyData,
		},
	}
	
	_, err = c.clientset.CoreV1().Secrets(namespace).Create(c.ctx, secret, metav1.CreateOptions{})
	if err != nil {
		c.metrics.RecordSecretError(namespace, "creation_failed")
		return fmt.Errorf("创建Secret失败: %v", err)
	}
	
	return nil
}

// handleError 处理错误
func (c *Controller) handleError(key string, err error) {
	c.logger.Errorf("处理命名空间失败 %s: %v", key, err)
	
	// 如果错误是暂时的，重新入队
	if c.workqueue.NumRequeues(key) < 5 {
		c.workqueue.AddRateLimited(key)
		return
	}
	
	// 超过重试次数，放弃处理
	c.workqueue.Forget(key)
	c.logger.Errorf("放弃处理命名空间，超过最大重试次数: %s", key)
}

// getTotalNamespaces 获取总命名空间数
func (c *Controller) getTotalNamespaces() int {
	namespaces, err := c.clientset.CoreV1().Namespaces().List(c.ctx, metav1.ListOptions{})
	if err != nil {
		c.logger.Errorf("获取命名空间列表失败: %v", err)
		return 0
	}
	
	count := 0
	for _, ns := range namespaces.Items {
		if !c.config.IsExcludedNamespace(ns.Name) {
			count++
		}
	}
	
	return count
}