package metrics

import (
	"net/http"
	"strconv"
	"sync"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// Metrics 指标管理器
type Metrics struct {
	namespaceCreatedCounter *prometheus.CounterVec
	secretCreatedCounter    *prometheus.CounterVec
	secretErrorCounter      *prometheus.CounterVec
	operationDuration       *prometheus.HistogramVec
	totalNamespaces         prometheus.Gauge
	totalSecrets            prometheus.Gauge
	
	mu sync.RWMutex
}

// NewMetrics 创建新的指标管理器
func NewMetrics() *Metrics {
	m := &Metrics{}
	
	// 命名空间创建计数器
	m.namespaceCreatedCounter = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "k8s_secrets_controller_namespace_created_total",
			Help: "Total number of namespace creation events",
		},
		[]string{"namespace"},
	)
	
	// Secret创建计数器
	m.secretCreatedCounter = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "k8s_secrets_controller_secret_created_total",
			Help: "Total number of TLS secrets created",
		},
		[]string{"namespace", "secret_name", "status"},
	)
	
	// Secret错误计数器
	m.secretErrorCounter = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "k8s_secrets_controller_secret_errors_total",
			Help: "Total number of secret creation errors",
		},
		[]string{"namespace", "error_type"},
	)
	
	// 操作耗时直方图
	m.operationDuration = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "k8s_secrets_controller_operation_duration_seconds",
			Help:    "Duration of controller operations",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"operation", "namespace"},
	)
	
	// 总命名空间数仪表
	m.totalNamespaces = prometheus.NewGauge(
		prometheus.GaugeOpts{
			Name: "k8s_secrets_controller_total_namespaces",
			Help: "Total number of namespaces being monitored",
		},
	)
	
	// 总Secret数仪表
	m.totalSecrets = prometheus.NewGauge(
		prometheus.GaugeOpts{
			Name: "k8s_secrets_controller_total_secrets",
			Help: "Total number of TLS secrets managed",
		},
	)
	
	// 注册所有指标
	prometheus.MustRegister(
		m.namespaceCreatedCounter,
		m.secretCreatedCounter,
		m.secretErrorCounter,
		m.operationDuration,
		m.totalNamespaces,
		m.totalSecrets,
	)
	
	return m
}

// RecordNamespaceCreated 记录命名空间创建事件
func (m *Metrics) RecordNamespaceCreated(namespace string) {
	m.namespaceCreatedCounter.WithLabelValues(namespace).Inc()
}

// RecordSecretCreated 记录Secret创建成功事件
func (m *Metrics) RecordSecretCreated(namespace, secretName string) {
	m.secretCreatedCounter.WithLabelValues(namespace, secretName, "success").Inc()
	m.updateTotalSecrets(1)
}

// RecordSecretError 记录Secret创建错误事件
func (m *Metrics) RecordSecretError(namespace, errorType string) {
	m.secretErrorCounter.WithLabelValues(namespace, errorType).Inc()
}

// RecordOperationDuration 记录操作耗时
func (m *Metrics) RecordOperationDuration(operation, namespace string, duration time.Duration) {
	m.operationDuration.WithLabelValues(operation, namespace).Observe(duration.Seconds())
}

// SetTotalNamespaces 设置总命名空间数
func (m *Metrics) SetTotalNamespaces(count int) {
	m.totalNamespaces.Set(float64(count))
}

// updateTotalSecrets 更新总Secret数
func (m *Metrics) updateTotalSecrets(delta int) {
	m.mu.Lock()
	defer m.mu.Unlock()
	
	currentValue := m.totalSecrets.Get()
	m.totalSecrets.Set(currentValue + float64(delta))
}

// StartMetricsServer 启动指标服务器
func (m *Metrics) StartMetricsServer(port int) error {
	http.Handle("/metrics", promhttp.Handler())
	
	server := &http.Server{
		Addr:         ":" + strconv.Itoa(port),
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
	}
	
	return server.ListenAndServe()
}

// GetMetricsHandler 获取指标处理器
func (m *Metrics) GetMetricsHandler() http.Handler {
	return promhttp.Handler()
}