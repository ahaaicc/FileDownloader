#!/bin/bash
# macOS 打包脚本 - 遵循 PyInstaller 最佳实践
# 使用优化的 spec 文件进行打包

set -e  # 遇到错误立即退出

echo "=== FileDownloader macOS 打包脚本 ==="
echo ""

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo "❌ 未找到 python3"
    exit 1
fi

echo "✓ Python: $(python3 --version)"

# 参数处理
MODE=${1:-gui}

if [[ "$MODE" != "gui" && "$MODE" != "console" && "$MODE" != "clean" ]]; then
    echo ""
    echo "用法: $0 [gui|console|clean]"
    echo "  gui     - GUI 应用（默认）"
    echo "  console - 控制台应用（调试）"
    echo "  clean   - 清理构建文件"
    exit 1
fi

# 清理模式
if [ "$MODE" == "clean" ]; then
    echo ""
    echo "🧹 清理构建文件..."
    rm -rf build dist FileDownloader.spec __pycache__
    echo "✅ 清理完成"
    exit 0
fi

# 查找 pyinstaller
PYINSTALLER_CMD=""
if command -v pyinstaller &> /dev/null; then
    PYINSTALLER_CMD="pyinstaller"
else
    for version in 3.14 3.13 3.12 3.11 3.10; do
        if [ -x "$HOME/Library/Python/$version/bin/pyinstaller" ]; then
            PYINSTALLER_CMD="$HOME/Library/Python/$version/bin/pyinstaller"
            break
        fi
    done
fi

if [ -z "$PYINSTALLER_CMD" ]; then
    echo "❌ 找不到 pyinstaller"
    echo "请运行: pip3 install --user pyinstaller"
    exit 1
fi

echo "✓ PyInstaller: $PYINSTALLER_CMD"
echo ""

# 检查依赖
echo "📥 检查依赖..."
pip3 show requests pyinstaller &> /dev/null || pip3 install --user -r requirements-macos.txt
echo ""

# 清理旧文件
rm -rf dist

# 打包
echo "🔨 开始打包 (模式: $MODE)..."
echo ""

if [ "$MODE" == "gui" ]; then
    # 使用优化的 spec 文件
    $PYINSTALLER_CMD --noconfirm FileDownloader-macos.spec
    
    # 检查结果
    if [ -d "dist/FileDownloader.app" ]; then
        APP_SIZE=$(du -sh dist/FileDownloader.app | awk '{print $1}')
        echo ""
        echo "✅ 打包成功！"
        echo ""
        echo "📦 应用信息:"
        echo "  位置: dist/FileDownloader.app"
        echo "  大小: $APP_SIZE"
        echo "  架构: Universal (Intel + Apple Silicon)"
        echo ""
        echo "🚀 使用方法:"
        echo "  1. 双击: open dist/FileDownloader.app"
        echo "  2. 终端: ./dist/FileDownloader.app/Contents/MacOS/FileDownloader"
        echo "  3. 安装: cp -r dist/FileDownloader.app /Applications/"
        echo ""
        echo "💡 提示: 首次运行需在系统设置中允许"
    else
        echo "❌ 打包失败"
        exit 1
    fi
else
    # 控制台模式
    $PYINSTALLER_CMD --noconfirm --console --onedir --name "FileDownloader" file_downloader.py
    
    if [ -d "dist/FileDownloader" ]; then
        echo ""
        echo "✅ 打包成功！"
        echo ""
        echo "📦 控制台应用: dist/FileDownloader/"
        echo "🚀 运行: ./dist/FileDownloader/FileDownloader"
    else
        echo "❌ 打包失败"
        exit 1
    fi
fi
