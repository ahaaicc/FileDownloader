#!/bin/bash
# macOS 高级打包脚本 - 使用 spec 文件进行精细控制

set -e

echo "=== FileDownloader macOS 高级打包脚本 ==="
echo ""

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo "❌ 未找到 python3"
    exit 1
fi

echo "✓ Python: $(python3 --version)"

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
    exit 1
fi

echo "✓ PyInstaller: $PYINSTALLER_CMD"
echo ""

# 安装依赖
echo "📥 检查依赖..."
pip3 show requests pyinstaller &> /dev/null || pip3 install --user -r requirements-macos.txt
echo ""

# 清理
echo "🧹 清理旧文件..."
rm -rf dist build
echo ""

# 使用 spec 文件打包
echo "🔨 使用 spec 文件打包..."
$PYINSTALLER_CMD --noconfirm FileDownloader-macos.spec

# 检查结果
if [ -d "dist/FileDownloader.app" ]; then
    APP_SIZE=$(du -sh dist/FileDownloader.app | awk '{print $1}')
    echo ""
    echo "✅ 打包成功！"
    echo ""
    echo "📦 应用信息:"
    echo "  名称: FileDownloader"
    echo "  位置: dist/FileDownloader.app"
    echo "  大小: $APP_SIZE"
    echo "  架构: Universal (Intel + Apple Silicon)"
    echo ""
    
    # 显示 .app 内部结构
    echo "📂 应用结构:"
    echo "  $(ls -lh dist/FileDownloader.app/Contents/MacOS/FileDownloader | awk '{print "可执行文件: " $5}')"
    
    echo ""
    echo "🚀 使用方法:"
    echo "  1. 双击运行: open dist/FileDownloader.app"
    echo "  2. 终端运行: ./dist/FileDownloader.app/Contents/MacOS/FileDownloader"
    echo "  3. 安装到系统: cp -r dist/FileDownloader.app /Applications/"
    echo ""
    echo "💡 提示:"
    echo "  - 使用 spec 文件可获得更好的控制和优化"
    echo "  - 支持 Universal Binary（Intel 和 Apple Silicon）"
    echo "  - 已排除不必要的模块以减小体积"
else
    echo "❌ 打包失败"
    exit 1
fi
