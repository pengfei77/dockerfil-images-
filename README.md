# Kubernetes Secrets Controller

一个基于 client-go 的 Kubernetes 控制器，用于自动监听 Namespace 创建事件并在新创建的 Namespace 中自动创建 TLS Secret。

## 功能特性

- ✅ 使用 client-go 的 Informer 机制监听 Namespace 创建事件
- ✅ 自动在新 Namespace 中创建 TLS Secret
- ✅ 支持通过环境变量配置证书路径
- ✅ 排除 kube-* 系统 Namespace 的处理
- ✅ 完善的错误处理和日志系统
- ✅ 完整的 RBAC 配置示例
- ✅ 优雅停止和信号处理

## 架构设计

### 核心组件

1. **配置管理** (`pkg/config/`)
   - 环境变量配置加载
   - 配置验证和默认值设置
   - 证书文件读取

2. **日志系统** (`pkg/logger/`)
   - 基于 logrus 的日志记录
   - 支持 JSON 和文本格式
   - 调用者信息追踪

3. **Kubernetes 客户端** (`pkg/k8s/`)
   - 集群内外配置自动检测
   - Namespace 和 Secret 操作封装
   - Informer 创建和管理

4. **控制器核心** (`pkg/controller/`)
   - Namespace 事件监听
   - 工作队列和重试机制
   - TLS Secret 创建逻辑

### 数据流

```
Namespace创建事件 → Informer → 工作队列 → 控制器处理 → TLS Secret创建
```

## 快速开始

### 1. 构建项目

```bash
# 克隆项目
git clone <repository-url>
cd secrets-controller

# 构建二进制文件
./build.sh build

# 或者构建所有内容
./build.sh all
```

### 2. 准备证书文件

创建自签名证书（用于测试）：

```bash
# 生成证书
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout key.key -out cert.crt \
  -subj "/CN=secrets-controller/O=system"

# 将证书文件放置在固定路径
mkdir -p /fixed/path
cp cert.crt key.key /fixed/path/
```

### 3. 运行控制器

```bash
# 设置环境变量
export CERT_FILE_PATH=/fixed/path/cert.crt
export KEY_FILE_PATH=/fixed/path/key.key

# 运行控制器
./bin/secrets-controller
```

## 配置说明

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `CERT_FILE_PATH` | **必须提供** | 证书文件路径（容器内路径） |
| `KEY_FILE_PATH` | **必须提供** | 私钥文件路径（容器内路径） |
| `SECRET_NAME` | `tls-secret` | 创建的 Secret 名称 |
| `THREADINESS` | `2` | 工作器线程数 |
| `RESYNC_PERIOD` | `30` | Informer 重新同步周期（秒） |
| `LOG_LEVEL` | `info` | 日志级别 |
| `LOG_FORMAT` | `text` | 日志格式（text/json） |
| `EXCLUDE_PREFIXES` | `kube-` | 排除的 Namespace 前缀 |

### 配置文件（可选）

控制器支持通过 ConfigMap 进行配置：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: secrets-controller-config
  namespace: kube-system
data:
  config.yaml: |
    certFilePath: /fixed/path/cert.crt
    keyFilePath: /fixed/path/key.key
    secretName: tls-secret
    threadiness: 2
    resyncPeriod: 30
    logLevel: info
    logFormat: json
    excludePrefixes: kube-
```

## Kubernetes 部署

### 1. 创建 RBAC 权限

```bash
kubectl apply -f deploy/rbac.yaml
```

### 2. 准备证书文件

将证书文件放置在容器内可访问的路径，例如：
- 使用 PersistentVolume 挂载
- 使用 ConfigMap 存储证书内容
- 在构建镜像时包含证书文件

### 3. 部署控制器

```bash
kubectl apply -f deploy/deployment.yaml
```

### 4. 验证部署

```bash
# 检查 Pod 状态
kubectl get pods -n kube-system -l app=secrets-controller

# 查看日志
kubectl logs -n kube-system -l app=secrets-controller
```



## 开发指南

### 项目结构

```
secrets-controller/
├── cmd/controller/           # 主程序入口
├── pkg/
│   ├── config/              # 配置管理
│   ├── controller/          # 控制器核心逻辑
│   ├── k8s/                 # Kubernetes 客户端封装
│   └── logger/              # 日志系统
├── deploy/                  # 部署配置文件
├── build.sh                 # 构建脚本
├── Dockerfile              # 容器镜像构建
└── README.md               # 项目文档
```

### 添加新功能

1. **扩展配置选项**
   - 在 `pkg/config/config.go` 中添加新字段
   - 更新环境变量处理逻辑

2. **添加新的资源监听**
   - 创建新的 Informer
   - 添加事件处理器
   - 更新 RBAC 权限

### 测试

```bash
# 运行单元测试
go test ./... -v

# 运行集成测试（需要Kubernetes集群）
go test ./... -tags=integration -v
```

## 故障排除

### 常见问题

1. **证书文件不存在**
   ```
   错误：读取证书文件失败
   ```
   解决方案：确保证书文件存在于配置的路径

2. **RBAC 权限不足**
   ```
   错误：创建Secret失败: secrets is forbidden
   ```
   解决方案：检查 RBAC 配置，确保有足够的权限

3. **无法连接 Kubernetes API**
   ```
   错误：获取Kubernetes配置失败
   ```
   解决方案：检查 kubeconfig 文件或集群内服务账户配置

### 日志分析

控制器提供详细的日志信息，可以通过以下方式查看：

```bash
# 查看详细日志
kubectl logs -n kube-system deployment/secrets-controller -f

# 查看特定级别的日志
kubectl logs -n kube-system deployment/secrets-controller --tail=100 | grep -i error
```

## 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 联系方式

- 项目主页：<repository-url>
- 问题反馈：<issues-url>
- 讨论区：<discussions-url>