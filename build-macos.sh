#!/bin/bash
# macOS 打包脚本

echo "=== FileDownloader macOS 打包脚本 ==="
echo ""

# 检查 Python 环境
if ! command -v python3 &> /dev/null; then
    echo "❌ 错误: 未找到 python3"
    exit 1
fi

echo "✓ Python 版本: $(python3 --version)"
echo ""

# 清理旧的构建文件
echo "📦 清理旧的构建文件..."
rm -rf build dist *.spec

# 安装依赖
echo ""
echo "📥 安装依赖..."
pip3 install --user -r requirements-macos.txt || {
    echo "⚠️  使用 --user 安装失败，尝试全局安装..."
    pip3 install -r requirements-macos.txt
}

# 打包应用
echo ""
echo "🔨 开始打包..."

# 尝试找到 pyinstaller 命令
PYINSTALLER_CMD=""
if command -v pyinstaller &> /dev/null; then
    PYINSTALLER_CMD="pyinstaller"
elif [ -x "$HOME/Library/Python/3.14/bin/pyinstaller" ]; then
    PYINSTALLER_CMD="$HOME/Library/Python/3.14/bin/pyinstaller"
elif [ -x "$HOME/Library/Python/3.13/bin/pyinstaller" ]; then
    PYINSTALLER_CMD="$HOME/Library/Python/3.13/bin/pyinstaller"
elif [ -x "$HOME/Library/Python/3.12/bin/pyinstaller" ]; then
    PYINSTALLER_CMD="$HOME/Library/Python/3.12/bin/pyinstaller"
else
    echo "❌ 找不到 pyinstaller 命令"
    echo "请运行: pip3 install pyinstaller"
    exit 1
fi

echo "使用: $PYINSTALLER_CMD"

# 注意：macOS 上不使用 --onefile，因为 .app bundle 本身就是独立包
$PYINSTALLER_CMD --windowed \
                 --name "FileDownloader" \
                 --clean \
                 file_downloader.py

# 检查打包结果
if [ -f "dist/FileDownloader.app/Contents/MacOS/FileDownloader" ]; then
    echo ""
    echo "✅ 打包成功！"
    echo "📍 应用位置: dist/FileDownloader.app"
    echo ""
    echo "使用方法："
    echo "  1. 双击运行: 直接双击 dist/FileDownloader.app"
    echo "  2. 终端运行: ./dist/FileDownloader.app/Contents/MacOS/FileDownloader"
else
    echo ""
    echo "❌ 打包失败，请检查错误信息"
    exit 1
fi
