#!/bin/bash

# Kubernetes Secrets Controller 构建脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印彩色信息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查依赖
check_dependencies() {
    print_info "检查构建依赖..."
    
    if ! command -v go &> /dev/null; then
        print_error "Go 未安装，请先安装 Go 1.21 或更高版本"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        print_warning "Docker 未安装，将跳过镜像构建"
        SKIP_DOCKER=true
    fi
    
    print_info "依赖检查完成"
}

# 构建二进制文件
build_binary() {
    print_info "构建二进制文件..."
    
    # 设置构建参数
    VERSION=${VERSION:-$(git describe --tags 2>/dev/null || echo "dev")}
    BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    GIT_COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
    
    # 构建
    CGO_ENABLED=0 go build -ldflags "\
        -X main.Version=$VERSION \
        -X main.BuildTime=$BUILD_TIME \
        -X main.GitCommit=$GIT_COMMIT" \
        -o bin/secrets-controller ./cmd/controller
    
    print_info "二进制文件构建完成: bin/secrets-controller"
}

# 构建Docker镜像
build_docker() {
    if [ "$SKIP_DOCKER" = true ]; then
        print_warning "跳过Docker镜像构建"
        return
    fi
    
    print_info "构建Docker镜像..."
    
    # 设置镜像标签
    IMAGE_NAME="${IMAGE_NAME:-secrets-controller}"
    IMAGE_TAG="${IMAGE_TAG:-latest}"
    
    # 构建镜像
    docker build -t "$IMAGE_NAME:$IMAGE_TAG" .
    
    print_info "Docker镜像构建完成: $IMAGE_NAME:$IMAGE_TAG"
}

# 运行测试
run_tests() {
    print_info "运行测试..."
    
    if go test ./...; then
        print_info "测试通过"
    else
        print_error "测试失败"
        exit 1
    fi
}

# 代码检查
run_lint() {
    print_info "运行代码检查..."
    
    # 检查是否有golangci-lint
    if command -v golangci-lint &> /dev/null; then
        golangci-lint run
        print_info "代码检查完成"
    else
        print_warning "golangci-lint 未安装，跳过代码检查"
    fi
}

# 清理
clean() {
    print_info "清理构建产物..."
    
    rm -rf bin/
    
    print_info "清理完成"
}

# 显示帮助信息
show_help() {
    echo "Kubernetes Secrets Controller 构建脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  build      构建二进制文件（默认）"
    echo "  docker     构建Docker镜像"
    echo "  test       运行测试"
    echo "  lint       运行代码检查"
    echo "  all        执行所有构建步骤"
    echo "  clean      清理构建产物"
    echo "  help       显示此帮助信息"
    echo ""
    echo "环境变量:"
    echo "  VERSION    设置版本号（默认: git tag或dev）"
    echo "  IMAGE_NAME 设置Docker镜像名称（默认: secrets-controller）"
    echo "  IMAGE_TAG  设置Docker镜像标签（默认: latest）"
}

# 主函数
main() {
    local action=${1:-build}
    
    case "$action" in
        build)
            check_dependencies
            build_binary
            ;;
        docker)
            check_dependencies
            build_docker
            ;;
        test)
            run_tests
            ;;
        lint)
            run_lint
            ;;
        all)
            check_dependencies
            run_lint
            run_tests
            build_binary
            build_docker
            ;;
        clean)
            clean
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "未知操作: $action"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"