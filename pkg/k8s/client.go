package k8s

import (
	"context"
	"fmt"
	"time"

	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/watch"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/cache"
	"k8s.io/client-go/tools/clientcmd"
)

// Client Kubernetes客户端封装
type Client struct {
	clientset *kubernetes.Clientset
	config    *rest.Config
}

// NewClient 创建新的Kubernetes客户端
func NewClient() (*Client, error) {
	config, err := getKubeConfig()
	if err != nil {
		return nil, fmt.Errorf("获取Kubernetes配置失败: %v", err)
	}

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		return nil, fmt.Errorf("创建Kubernetes客户端失败: %v", err)
	}

	return &Client{
		clientset: clientset,
		config:    config,
	}, nil
}

// CreateTLSSecret 创建TLS Secret
func (c *Client) CreateTLSSecret(ctx context.Context, namespace, name string, certData, keyData []byte) error {
	secret := &corev1.Secret{
		ObjectMeta: metav1.ObjectMeta{
			Name:      name,
			Namespace: namespace,
		},
		Type: corev1.SecretTypeTLS,
		Data: map[string][]byte{
			"tls.crt": certData,
			"tls.key": keyData,
		},
	}

	_, err := c.clientset.CoreV1().Secrets(namespace).Create(ctx, secret, metav1.CreateOptions{})
	if err != nil {
		return fmt.Errorf("创建Secret失败: %v", err)
	}

	return nil
}

// SecretExists 检查Secret是否存在
func (c *Client) SecretExists(ctx context.Context, namespace, name string) (bool, error) {
	_, err := c.clientset.CoreV1().Secrets(namespace).Get(ctx, name, metav1.GetOptions{})
	if err != nil {
		return false, nil
	}
	return true, nil
}

// ListNamespaces 列出所有Namespace
func (c *Client) ListNamespaces(ctx context.Context) ([]corev1.Namespace, error) {
	list, err := c.clientset.CoreV1().Namespaces().List(ctx, metav1.ListOptions{})
	if err != nil {
		return nil, fmt.Errorf("列出Namespace失败: %v", err)
	}
	return list.Items, nil
}

// NamespaceExists 检查Namespace是否存在
func (c *Client) NamespaceExists(ctx context.Context, name string) (bool, error) {
	_, err := c.clientset.CoreV1().Namespaces().Get(ctx, name, metav1.GetOptions{})
	if err != nil {
		return false, nil
	}
	return true, nil
}

// WatchNamespaces 监听Namespace事件
func (c *Client) WatchNamespaces(ctx context.Context) (watch.Interface, error) {
	watcher, err := c.clientset.CoreV1().Namespaces().Watch(ctx, metav1.ListOptions{
		Watch: true,
	})
	if err != nil {
		return nil, fmt.Errorf("创建Namespace监听器失败: %v", err)
	}
	return watcher, nil
}

// CreateNamespaceInformer 创建Namespace Informer
func (c *Client) CreateNamespaceInformer(resyncPeriod time.Duration) cache.SharedIndexInformer {
	// 创建Namespace Informer
	informer := cache.NewSharedIndexInformer(
		&cache.ListWatch{
			ListFunc: func(options metav1.ListOptions) (runtime.Object, error) {
				return c.clientset.CoreV1().Namespaces().List(ctx, options)
			},
			WatchFunc: func(options metav1.ListOptions) (watch.Interface, error) {
				return c.clientset.CoreV1().Namespaces().Watch(ctx, options)
			},
		},
		&corev1.Namespace{},
		resyncPeriod,
		cache.Indexers{},
	)

	return informer
}

// GetConfig 获取Kubernetes配置
func (c *Client) GetConfig() *rest.Config {
	return c.config
}

// GetClientset 获取原始客户端
func (c *Client) GetClientset() *kubernetes.Clientset {
	return c.clientset
}

// getKubeConfig 获取Kubernetes配置
func getKubeConfig() (*rest.Config, error) {
	// 首先尝试使用集群内配置
	config, err := rest.InClusterConfig()
	if err == nil {
		return config, nil
	}

	// 如果不在集群内，尝试使用kubeconfig文件
	loadingRules := clientcmd.NewDefaultClientConfigLoadingRules()
	configOverrides := &clientcmd.ConfigOverrides{}
	clientConfig := clientcmd.NewNonInteractiveDeferredLoadingClientConfig(loadingRules, configOverrides)

	return clientConfig.ClientConfig()
}

// ctx 全局上下文变量
var ctx = context.Background()