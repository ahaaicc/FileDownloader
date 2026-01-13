#!/bin/bash
# macOS 打包脚本 - 动态打包，不依赖 spec 文件
# 使用 PyInstaller 自动检测依赖，确保长期稳定性

set -e  # 遇到错误立即退出

echo "=== FileDownloader macOS 打包脚本 ==="
echo ""

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo "❌ 未找到 python3"
    exit 1
fi

PYTHON_VERSION=$(python3 --version)
echo "✓ Python: $PYTHON_VERSION"

# 参数处理
MODE=${1:-gui}

if [[ "$MODE" != "gui" && "$MODE" != "console" && "$MODE" != "clean" ]]; then
    echo ""
    echo "用法: $0 [gui|console|clean]"
    echo ""
    echo "模式说明:"
    echo "  gui     - GUI 应用（默认，无终端窗口）"
    echo "  console - 控制台应用（有终端窗口，便于调试）"
    echo "  clean   - 清理所有构建文件"
    echo ""
    echo "示例:"
    echo "  $0        # 默认 GUI 模式"
    echo "  $0 gui    # GUI 模式"
    echo "  $0 console # 控制台模式"
    echo "  $0 clean  # 清理"
    exit 1
fi

# 清理模式
if [ "$MODE" == "clean" ]; then
    echo ""
    echo "🧹 清理构建文件..."
    rm -rf build dist *.spec __pycache__ .eggs *.egg-info
    echo "✅ 清理完成"
    exit 0
fi

# 查找 pyinstaller
PYINSTALLER_CMD=""
if command -v pyinstaller &> /dev/null; then
    PYINSTALLER_CMD="pyinstaller"
else
    # 在用户 Python 目录中查找
    for version in 3.14 3.13 3.12 3.11 3.10; do
        if [ -x "$HOME/Library/Python/$version/bin/pyinstaller" ]; then
            PYINSTALLER_CMD="$HOME/Library/Python/$version/bin/pyinstaller"
            break
        fi
    done
fi

if [ -z "$PYINSTALLER_CMD" ]; then
    echo "❌ 找不到 pyinstaller"
    echo ""
    echo "请安装 pyinstaller:"
    echo "  pip3 install --user pyinstaller"
    echo ""
    echo "或安装所有依赖:"
    echo "  pip3 install --user -r requirements-macos.txt"
    exit 1
fi

PYINSTALLER_VERSION=$($PYINSTALLER_CMD --version 2>/dev/null || echo "unknown")
echo "✓ PyInstaller: $PYINSTALLER_VERSION"
echo ""

# 检查依赖
echo "📥 检查依赖..."
if ! pip3 show requests &> /dev/null || ! pip3 show pyinstaller &> /dev/null; then
    echo "正在安装缺失的依赖..."
    pip3 install --user -r requirements-macos.txt
    echo "✓ 依赖安装完成"
else
    echo "✓ 所有依赖已安装"
fi
echo ""

# 清理旧的构建文件
echo "🧹 清理旧的构建文件..."
rm -rf dist build *.spec
echo ""

# 开始打包
echo "🔨 开始打包 (模式: $MODE)..."
echo ""

if [ "$MODE" == "gui" ]; then
    # GUI 模式 - 让 PyInstaller 自动处理所有事情
    echo "使用 GUI 模式打包..."
    $PYINSTALLER_CMD \
        --name "FileDownloader" \
        --onedir \
        --noconfirm \
        --clean \
        --noupx \
        file_downloader.py
    
    # 检查是否生成了 .app bundle
    if [ -d "dist/FileDownloader.app" ]; then
        APP_SIZE=$(du -sh dist/FileDownloader.app | awk '{print $1}')
        echo ""
        echo "✅ 打包成功！"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📦 应用信息"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  名称: FileDownloader"
        echo "  位置: dist/FileDownloader.app"
        echo "  大小: $APP_SIZE"
        echo "  类型: macOS 应用包 (.app)"
        
        # 检测架构
        ARCH=$(file dist/FileDownloader.app/Contents/MacOS/FileDownloader | grep -o "arm64\|x86_64" | head -1)
        if [ -n "$ARCH" ]; then
            echo "  架构: $ARCH"
        fi
        
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🚀 使用方法"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "  方式1: 双击运行"
        echo "    → open dist/FileDownloader.app"
        echo ""
        echo "  方式2: 从终端运行（可查看日志）"
        echo "    → ./dist/FileDownloader.app/Contents/MacOS/FileDownloader"
        echo ""
        echo "  方式3: 安装到系统应用文件夹"
        echo "    → cp -r dist/FileDownloader.app /Applications/"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "💡 提示"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  • 首次运行可能需要在【系统设置】→【隐私与安全性】"
        echo "    中允许运行"
        echo "  • 如需查看运行日志，使用方式2从终端启动"
        echo "  • 应用包含所有依赖，可复制到其他 Mac 使用"
        echo ""
        
    elif [ -d "dist/FileDownloader" ]; then
        # 如果没有生成 .app，可能是 Python/PyInstaller 配置问题
        FOLDER_SIZE=$(du -sh dist/FileDownloader | awk '{print $1}')
        echo ""
        echo "⚠️  未生成 .app bundle，但打包成功"
        echo ""
        echo "📦 应用信息:"
        echo "  位置: dist/FileDownloader/"
        echo "  大小: $FOLDER_SIZE"
        echo ""
        echo "🚀 运行方法:"
        echo "  ./dist/FileDownloader/FileDownloader"
        echo ""
        echo "💡 提示: 如需 .app bundle，请使用高级打包脚本:"
        echo "  ./build-macos-advanced.sh"
        echo ""
    else
        echo ""
        echo "❌ 打包失败，未找到输出文件"
        exit 1
    fi
    
else
    # Console 模式 - 用于调试
    echo "使用控制台模式打包..."
    $PYINSTALLER_CMD \
        --name "FileDownloader" \
        --onedir \
        --console \
        --noconfirm \
        --clean \
        --noupx \
        file_downloader.py
    
    if [ -d "dist/FileDownloader" ]; then
        FOLDER_SIZE=$(du -sh dist/FileDownloader | awk '{print $1}')
        echo ""
        echo "✅ 打包成功！"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📦 控制台应用"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  位置: dist/FileDownloader/"
        echo "  大小: $FOLDER_SIZE"
        echo "  模式: 调试模式（显示终端窗口）"
        echo ""
        echo "🚀 运行方法:"
        echo "  ./dist/FileDownloader/FileDownloader"
        echo ""
        echo "💡 此模式会显示终端窗口和所有日志输出"
        echo ""
    else
        echo ""
        echo "❌ 打包失败"
        exit 1
    fi
fi
