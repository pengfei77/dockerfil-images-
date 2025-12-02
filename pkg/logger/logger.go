package logger

import (
	"fmt"
	"io"
	"os"
	"runtime"
	"strings"
	"time"

	"github.com/sirupsen/logrus"
)

// Logger 日志记录器接口
type Logger interface {
	Debug(args ...interface{})
	Debugf(format string, args ...interface{})
	Info(args ...interface{})
	Infof(format string, args ...interface{})
	Warn(args ...interface{})
	Warnf(format string, args ...interface{})
	Error(args ...interface{})
	Errorf(format string, args ...interface{})
	Fatal(args ...interface{})
	Fatalf(format string, args ...interface{})
	WithField(key string, value interface{}) Logger
	WithFields(fields map[string]interface{}) Logger
}

// LogrusLogger 基于logrus的日志记录器实现
type LogrusLogger struct {
	entry *logrus.Entry
}

// NewLogger 创建新的日志记录器
func NewLogger(level, format string, output io.Writer) (Logger, error) {
	logrusLogger := logrus.New()
	
	// 设置日志级别
	logLevel, err := logrus.ParseLevel(level)
	if err != nil {
		return nil, fmt.Errorf("无效的日志级别: %s", level)
	}
	logrusLogger.SetLevel(logLevel)
	
	// 设置日志格式
	if strings.ToLower(format) == "json" {
		logrusLogger.SetFormatter(&logrus.JSONFormatter{
			TimestampFormat: time.RFC3339,
		})
	} else {
		logrusLogger.SetFormatter(&logrus.TextFormatter{
			FullTimestamp:   true,
			TimestampFormat: time.RFC3339,
			ForceColors:     true,
		})
	}
	
	// 设置输出
	if output != nil {
		logrusLogger.SetOutput(output)
	} else {
		logrusLogger.SetOutput(os.Stdout)
	}
	
	// 添加调用者信息
	logrusLogger.SetReportCaller(true)
	
	return &LogrusLogger{
		entry: logrus.NewEntry(logrusLogger),
	}, nil
}

// Debug 记录调试级别日志
func (l *LogrusLogger) Debug(args ...interface{}) {
	l.entry.WithField("caller", getCallerInfo()).Debug(args...)
}

// Debugf 记录格式化调试级别日志
func (l *LogrusLogger) Debugf(format string, args ...interface{}) {
	l.entry.WithField("caller", getCallerInfo()).Debugf(format, args...)
}

// Info 记录信息级别日志
func (l *LogrusLogger) Info(args ...interface{}) {
	l.entry.WithField("caller", getCallerInfo()).Info(args...)
}

// Infof 记录格式化信息级别日志
func (l *LogrusLogger) Infof(format string, args ...interface{}) {
	l.entry.WithField("caller", getCallerInfo()).Infof(format, args...)
}

// Warn 记录警告级别日志
func (l *LogrusLogger) Warn(args ...interface{}) {
	l.entry.WithField("caller", getCallerInfo()).Warn(args...)
}

// Warnf 记录格式化警告级别日志
func (l *LogrusLogger) Warnf(format string, args ...interface{}) {
	l.entry.WithField("caller", getCallerInfo()).Warnf(format, args...)
}

// Error 记录错误级别日志
func (l *LogrusLogger) Error(args ...interface{}) {
	l.entry.WithField("caller", getCallerInfo()).Error(args...)
}

// Errorf 记录格式化错误级别日志
func (l *LogrusLogger) Errorf(format string, args ...interface{}) {
	l.entry.WithField("caller", getCallerInfo()).Errorf(format, args...)
}

// Fatal 记录致命错误级别日志并退出
func (l *LogrusLogger) Fatal(args ...interface{}) {
	l.entry.WithField("caller", getCallerInfo()).Fatal(args...)
}

// Fatalf 记录格式化致命错误级别日志并退出
func (l *LogrusLogger) Fatalf(format string, args ...interface{}) {
	l.entry.WithField("caller", getCallerInfo()).Fatalf(format, args...)
}

// WithField 添加字段到日志记录器
func (l *LogrusLogger) WithField(key string, value interface{}) Logger {
	return &LogrusLogger{entry: l.entry.WithField(key, value)}
}

// WithFields 添加多个字段到日志记录器
func (l *LogrusLogger) WithFields(fields map[string]interface{}) Logger {
	return &LogrusLogger{entry: l.entry.WithFields(logrus.Fields(fields))}
}

// getCallerInfo 获取调用者信息
func getCallerInfo() string {
	_, file, line, ok := runtime.Caller(3) // 跳过3层调用栈
	if !ok {
		return "unknown"
	}
	
	// 简化文件路径
	parts := strings.Split(file, "/")
	if len(parts) > 2 {
		file = strings.Join(parts[len(parts)-2:], "/")
	}
	
	return fmt.Sprintf("%s:%d", file, line)
}

// DefaultLogger 默认日志记录器
var DefaultLogger Logger

func init() {
	var err error
	DefaultLogger, err = NewLogger("info", "text", nil)
	if err != nil {
		panic(fmt.Sprintf("创建默认日志记录器失败: %v", err))
	}
}