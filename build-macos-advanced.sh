#!/bin/bash
# macOS 高级打包脚本 - 使用虚拟环境（最佳实践）
# 动态生成优化配置，依赖完全隔离

set -e

echo "=== FileDownloader macOS 高级打包脚本（虚拟环境）==="
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
    echo "🧹 清理所有文件（包括虚拟环境）..."
    rm -rf build dist *.spec __pycache__ .eggs *.egg-info venv
    echo "✅ 清理完成"
    exit 0
fi

# 虚拟环境目录
VENV_DIR="venv"

# 检查是否已在虚拟环境中
if [ -n "$VIRTUAL_ENV" ]; then
    echo ""
    echo "⚠️  检测到已激活的虚拟环境: $VIRTUAL_ENV"
    echo "正在停用以使用项目虚拟环境..."
    deactivate 2>/dev/null || true
fi

# 创建虚拟环境（如果不存在）
if [ ! -d "$VENV_DIR" ]; then
    echo ""
    echo "📦 创建虚拟环境..."
    python3 -m venv "$VENV_DIR"
    echo "✓ 虚拟环境创建完成"
fi

# 激活虚拟环境
echo ""
echo "🔌 激活项目虚拟环境..."
source "$VENV_DIR/bin/activate"
echo "✓ 虚拟环境已激活: $VENV_DIR"

# 升级 pip
echo ""
echo "📥 升级 pip..."
pip install --upgrade pip -q
echo "✓ pip 已更新"

# 安装依赖
echo ""
echo "📥 安装/检查依赖..."
if [ -f "requirements-macos.txt" ]; then
    pip install -r requirements-macos.txt -q
else
    pip install requests pyinstaller -q
fi
echo "✓ 依赖已安装"

# 显示 PyInstaller 版本
PYINSTALLER_VERSION=$(pyinstaller --version 2>/dev/null || echo "unknown")
echo "✓ PyInstaller: $PYINSTALLER_VERSION"
echo ""

# 清理
echo "🧹 清理旧文件..."
rm -rf dist build *.spec
echo ""

# 第一步：生成基础 spec 文件
echo "🔨 步骤 1/3: 生成配置文件..."
pyinstaller \
    --name "FileDownloader" \
    --onedir \
    --noconfirm \
    file_downloader.py \
    > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✓ 配置文件已生成"
else
    echo "❌ 配置文件生成失败"
    deactivate
    exit 1
fi
echo ""

# 第二步：修改 spec 文件进行优化
echo "🔧 步骤 2/3: 优化配置..."

# 使用 Python 脚本修改 spec 文件
python3 << 'PYTHON_SCRIPT'
import re

spec_file = "FileDownloader.spec"

# 读取 spec 文件
with open(spec_file, 'r') as f:
    content = f.read()

# 优化配置
optimizations = {
    # 禁用 UPX（macOS 不推荐）
    "upx=True": "upx=False",
    
    # 禁用 strip（保留调试信息）
    "strip=False": "strip=False",
    
    # 设置 console=False（GUI 模式）
    "console=True": "console=False",
    
    # 添加 bundle 标识符（如果是 macOS .app）
    "codesign_identity=None": "codesign_identity=None",
}

for old, new in optimizations.items():
    content = content.replace(old, new)

# 在 Analysis 部分添加排除项以减小体积
if "excludes=[]" in content:
    excludes = """excludes=[
        'matplotlib', 'numpy', 'pandas', 'scipy', 'PIL',
        'PyQt5', 'PyQt6', 'PySide2', 'PySide6', 'wx'
    ]"""
    content = content.replace("excludes=[]", excludes)

# 添加 macOS .app bundle 支持
if "name='FileDownloader'," in content and "BUNDLE" not in content:
    # 在文件末尾添加 BUNDLE 配置
    bundle_config = """
# 创建 macOS .app bundle
app = BUNDLE(
    coll,
    name='FileDownloader.app',
    icon=None,
    bundle_identifier='com.filedownloader.app',
    version='1.0.0',
    info_plist={
        'CFBundleName': 'FileDownloader',
        'CFBundleDisplayName': 'File Downloader',
        'CFBundleVersion': '1.0.0',
        'CFBundleShortVersionString': '1.0.0',
        'NSHighResolutionCapable': True,
        'NSRequiresAquaSystemAppearance': False,
        'LSMinimumSystemVersion': '10.13.0',
    },
)
"""
    content = content.rstrip() + "\n" + bundle_config

# 保存修改后的 spec
with open(spec_file, 'w') as f:
    f.write(content)

print("✓ 配置优化完成")
PYTHON_SCRIPT

echo ""

# 第三步：使用优化后的 spec 重新打包
echo "📦 步骤 3/3: 执行打包..."
pyinstaller --noconfirm FileDownloader.spec

# 检查结果
echo ""
if [ -d "dist/FileDownloader.app" ]; then
    APP_SIZE=$(du -sh dist/FileDownloader.app | awk '{print $1}')
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ 高级打包成功！"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📦 应用信息:"
    echo "  名称: FileDownloader"
    echo "  位置: dist/FileDownloader.app"
    echo "  大小: $APP_SIZE"
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
    echo "🚀 使用方法"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  方式1: 双击运行"
    echo "    → open dist/FileDownloader.app"
    echo ""
    echo "  方式2: 从终端运行"
    echo "    → ./dist/FileDownloader.app/Contents/MacOS/FileDownloader"
    echo ""
    echo "  方式3: 安装到系统"
    echo "    → cp -r dist/FileDownloader.app /Applications/"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✨ 高级打包特性"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ✓ 生成 .app bundle（专业图标样式）"
    echo "  ✓ 排除不必要的模块（体积更小）"
    echo "  ✓ 优化的 bundle 元数据"
    echo "  ✓ 动态生成配置（不会过时）"
    echo ""
    
elif [ -d "dist/FileDownloader" ]; then
    FOLDER_SIZE=$(du -sh dist/FileDownloader | awk '{print $1}')
    
    echo "⚠️  生成了文件夹而非 .app bundle"
    echo ""
    echo "📦 应用信息:"
    echo "  位置: dist/FileDownloader/"
    echo "  大小: $FOLDER_SIZE"
    echo ""
    echo "🚀 运行方法:"
    echo "  ./dist/FileDownloader/FileDownloader"
    echo ""
    echo "💡 这可能是由于 PyInstaller 版本或配置问题"
    echo "   应用功能完全正常，只是没有 .app 外壳"
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
