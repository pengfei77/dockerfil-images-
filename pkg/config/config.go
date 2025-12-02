package config

import (
	"os"
	"strings"
)

// Config 控制器配置
type Config struct {
	// 证书文件路径（必须提供）
	CertFilePath string `env:"CERT_FILE_PATH"`
	KeyFilePath  string `env:"KEY_FILE_PATH"`
	
	// Secret配置
	SecretName string `env:"SECRET_NAME" default:"tls-secret"`
	
	// 控制器配置
	Threadiness     int    `env:"THREADINESS" default:"2"`
	ResyncPeriod    int    `env:"RESYNC_PERIOD" default:"30"`
	MetricsPort     int    `env:"METRICS_PORT" default:"8080"`
	
	// 日志配置
	LogLevel        string `env:"LOG_LEVEL" default:"info"`
	LogFormat       string `env:"LOG_FORMAT" default:"text"`
	
	// 排除的Namespace前缀
	ExcludePrefixes []string `env:"EXCLUDE_PREFIXES" default:"kube-"`
}

// LoadConfig 从环境变量加载配置
func LoadConfig() *Config {
	cfg := &Config{}
	
	// 设置默认值
	cfg.CertFilePath = getEnv("CERT_FILE_PATH", "/fixed/path/cert.crt")
	cfg.KeyFilePath = getEnv("KEY_FILE_PATH", "/fixed/path/key.key")
	cfg.SecretName = getEnv("SECRET_NAME", "tls-secret")
	cfg.Threadiness = getEnvInt("THREADINESS", 2)
	cfg.ResyncPeriod = getEnvInt("RESYNC_PERIOD", 30)
	cfg.MetricsPort = getEnvInt("METRICS_PORT", 8080)
	cfg.LogLevel = getEnv("LOG_LEVEL", "info")
	cfg.LogFormat = getEnv("LOG_FORMAT", "text")
	
	// 处理排除前缀
	excludePrefixes := getEnv("EXCLUDE_PREFIXES", "kube-")
	cfg.ExcludePrefixes = strings.Split(excludePrefixes, ",")
	
	return cfg
}

// Validate 验证配置
func (c *Config) Validate() error {
	// 验证证书文件路径
	if c.CertFilePath == "" {
		return &ConfigError{Field: "CERT_FILE_PATH", Message: "证书文件路径不能为空"}
	}
	if c.KeyFilePath == "" {
		return &ConfigError{Field: "KEY_FILE_PATH", Message: "私钥文件路径不能为空"}
	}
	
	// 验证Secret名称
	if c.SecretName == "" {
		return &ConfigError{Field: "SECRET_NAME", Message: "Secret名称不能为空"}
	}
	
	// 验证端口范围
	if c.MetricsPort < 1 || c.MetricsPort > 65535 {
		return &ConfigError{Field: "METRICS_PORT", Message: "端口号必须在1-65535之间"}
	}
	
	return nil
}

// IsExcludedNamespace 检查Namespace是否应该被排除
func (c *Config) IsExcludedNamespace(namespace string) bool {
	for _, prefix := range c.ExcludePrefixes {
		if strings.HasPrefix(namespace, prefix) {
			return true
		}
	}
	return false
}

// GetCertificateData 读取证书文件内容
func (c *Config) GetCertificateData() ([]byte, []byte, error) {
	certData, err := os.ReadFile(c.CertFilePath)
	if err != nil {
		return nil, nil, err
	}
	
	keyData, err := os.ReadFile(c.KeyFilePath)
	if err != nil {
		return nil, nil, err
	}
	
	return certData, keyData, nil
}

// ConfigError 配置错误
type ConfigError struct {
	Field   string
	Message string
}

func (e *ConfigError) Error() string {
	return e.Field + ": " + e.Message
}

// 辅助函数
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvInt(key string, defaultValue int) int {
	value := getEnv(key, "")
	if value == "" {
		return defaultValue
	}
	
	// 简单的字符串转整数（实际项目中应该使用strconv）
	var result int
	for _, ch := range value {
		if ch >= '0' && ch <= '9' {
			result = result*10 + int(ch-'0')
		}
	}
	
	if result == 0 {
		return defaultValue
	}
	return result
}