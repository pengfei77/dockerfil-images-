package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"k8s-secrets-controller/pkg/config"
	"k8s-secrets-controller/pkg/controller"
	"k8s-secrets-controller/pkg/logger"
	"k8s-secrets-controller/pkg/metrics"
)

// 版本信息
var (
	Version   = "dev"
	BuildTime = "unknown"
	GitCommit = "unknown"
)

func main() {
	// 打印版本信息
	fmt.Printf("Kubernetes Secrets Controller\n")
	fmt.Printf("Version: %s\n", Version)
	fmt.Printf("Build Time: %s\n", BuildTime)
	fmt.Printf("Git Commit: %s\n", GitCommit)
	fmt.Println()

	// 加载配置
	cfg := config.LoadConfig()

	// 验证配置
	if err := cfg.Validate(); err != nil {
		fmt.Fprintf(os.Stderr, "配置验证失败: %v\n", err)
		os.Exit(1)
	}

	// 创建日志记录器
	log, err := logger.NewLogger(cfg.LogLevel, cfg.LogFormat, nil)
	if err != nil {
		fmt.Fprintf(os.Stderr, "创建日志记录器失败: %v\n", err)
		os.Exit(1)
	}

	log.Info("启动Kubernetes Secrets控制器")
	log.Infof("配置: %+v", cfg)

	// 创建指标管理器
	metricsManager := metrics.NewMetrics()

	// 启动指标服务器
	go func() {
		log.Infof("启动指标服务器，端口: %d", cfg.MetricsPort)
		
		http.Handle("/metrics", metricsManager.GetMetricsHandler())
		http.HandleFunc("/health", healthHandler)
		http.HandleFunc("/ready", readyHandler)
		
		server := &http.Server{
			Addr: fmt.Sprintf(":%d", cfg.MetricsPort),
		}
		
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Errorf("指标服务器启动失败: %v", err)
			os.Exit(1)
		}
	}()

	// 创建控制器
	ctrl, err := controller.NewController(cfg, log, metricsManager)
	if err != nil {
		log.Errorf("创建控制器失败: %v", err)
		os.Exit(1)
	}

	// 设置信号处理
	signalChan := make(chan os.Signal, 1)
	signal.Notify(signalChan, syscall.SIGINT, syscall.SIGTERM)

	// 启动控制器
	errChan := make(chan error, 1)
	go func() {
		if err := ctrl.Run(cfg.Threadiness); err != nil {
			errChan <- err
		}
	}()

	log.Info("控制器已启动，等待事件...")

	// 等待信号或错误
	select {
	case sig := <-signalChan:
		log.Infof("接收到信号: %v，开始优雅停止", sig)
		
		// 优雅停止
		stopCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()
		
		ctrl.Stop()
		
		log.Info("控制器已停止")
		
	case err := <-errChan:
		log.Errorf("控制器运行错误: %v", err)
		os.Exit(1)
	}
}

// healthHandler 健康检查处理器
func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("OK"))
}

// readyHandler 就绪检查处理器
func readyHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("OK"))
}