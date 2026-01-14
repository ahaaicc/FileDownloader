#!/bin/bash
# macOS 轻量级打包脚本 - 优化体积
# 在保持 macOS 最佳实践的同时尽可能减小体积

set -e

echo "=== FileDownloader macOS 轻量级打包 ==="
echo ""

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo "❌ 未找到 python3"
    exit 1
fi

echo "✓ Python: $(python3 --version)"

# 参数处理
MODE=${1:-build}

if [[ "$MODE" == "clean" ]]; then
    echo ""
    echo "🧹 清理所有文件..."
    rm -rf build dist *.spec __pycache__ .eggs *.egg-info venv
    echo "✅ 清理完成"
    exit 0
fi

# 虚拟环境
VENV_DIR="venv"

# 检查并停用已激活的虚拟环境
if [ -n "$VIRTUAL_ENV" ]; then
    echo ""
    echo "⚠️  检测到已激活的虚拟环境"
    echo "正在停用..."
    deactivate 2>/dev/null || true
fi

# 创建虚拟环境
if [ ! -d "$VENV_DIR" ]; then
    echo ""
    echo "📦 创建虚拟环境..."
    python3 -m venv "$VENV_DIR"
    echo "✓ 虚拟环境创建完成"
fi

# 激活虚拟环境
echo ""
echo "🔌 激活虚拟环境..."
source "$VENV_DIR/bin/activate"
echo "✓ 虚拟环境已激活"

# 安装依赖
echo ""
echo "📥 安装依赖..."
pip install --upgrade pip -q
pip install -r requirements-macos.txt -q
echo "✓ 依赖已安装"
echo ""

# 清理旧文件
rm -rf dist build *.spec

echo "🔨 开始轻量级打包..."
echo ""
echo "优化策略："
echo "  • 排除不必要的模块"
echo "  • 优化 Python 字节码"
echo "  • 使用 --onedir 模式（保持 macOS 最佳实践）"
echo "  • 不使用 UPX（避免兼容性问题）"
echo ""

# 使用优化参数打包
pyinstaller \
    --name "FileDownloader" \
    --onedir \
    --noconfirm \
    --clean \
    --noupx \
    --optimize 2 \
    --exclude-module matplotlib \
    --exclude-module numpy \
    --exclude-module pandas \
    --exclude-module scipy \
    --exclude-module PIL \
    --exclude-module PyQt5 \
    --exclude-module PyQt6 \
    --exclude-module PySide2 \
    --exclude-module PySide6 \
    --exclude-module wx \
    --exclude-module IPython \
    --exclude-module jupyter \
    --exclude-module notebook \
    --exclude-module sphinx \
    --exclude-module pytest \
    --exclude-module unittest \
    file_downloader.py

# 检查结果
echo ""
if [ -d "dist/FileDownloader.app" ]; then
    APP_SIZE=$(du -sh dist/FileDownloader.app | awk '{print $1}')
    ORIGINAL_SIZE=35  # 原始大小约35MB
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ 轻量级打包成功！"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📦 应用信息:"
    echo "  名称: FileDownloader"
    echo "  位置: dist/FileDownloader.app"
    echo "  大小: $APP_SIZE (优化后)"
    echo "  类型: macOS 应用包 (.app)"
    
    # 检测架构
    if [ -f "dist/FileDownloader.app/Contents/MacOS/FileDownloader" ]; then
        ARCH=$(file dist/FileDownloader.app/Contents/MacOS/FileDownloader | grep -o "arm64\|x86_64" | head -1)
        if [ -n "$ARCH" ]; then
            echo "  架构: $ARCH"
        fi
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎯 优化说明"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ✓ 排除了不必要的大型库"
    echo "  ✓ 优化了 Python 字节码 (optimize=2)"
    echo "  ✓ 保持 --onedir 模式（macOS 最佳实践）"
    echo "  ✓ 生成 .app bundle（专业外观）"
    echo ""
    echo "💡 为什么不用 --onefile？"
    echo "  • --onefile 在 macOS 上启动慢（需要解压）"
    echo "  • 与 .app bundle 不兼容"
    echo "  • 可能触发安全警告"
    echo "  • 当前 --onedir 模式已经是最优方案"
    echo ""
    echo "🚀 使用方法:"
    echo "  open dist/FileDownloader.app"
    echo ""
    
elif [ -d "dist/FileDownloader" ]; then
    FOLDER_SIZE=$(du -sh dist/FileDownloader | awk '{print $1}')
    
    echo "✅ 打包成功（文件夹模式）"
    echo ""
    echo "📦 应用信息:"
    echo "  位置: dist/FileDownloader/"
    echo "  大小: $FOLDER_SIZE"
    echo ""
    echo "🚀 运行: ./dist/FileDownloader/FileDownloader"
    echo ""
else
    echo "❌ 打包失败"
    deactivate
    exit 1
fi

# 停用虚拟环境
deactivate
echo ""
echo "✓ 虚拟环境已停用"
echo ""
