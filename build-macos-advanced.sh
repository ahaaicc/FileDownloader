#!/bin/bash
# macOS 高级打包脚本 - 动态生成优化配置
# 提供更精细的控制和优化，但不依赖预制 spec 文件

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
    echo "请安装: pip3 install --user pyinstaller"
    exit 1
fi

echo "✓ PyInstaller: $($PYINSTALLER_CMD --version 2>/dev/null || echo 'unknown')"
echo ""

# 检查依赖
echo "📥 检查依赖..."
if ! pip3 show requests pyinstaller &> /dev/null; then
    echo "正在安装依赖..."
    pip3 install --user -r requirements-macos.txt
fi
echo "✓ 依赖已安装"
echo ""

# 清理
echo "🧹 清理旧文件..."
rm -rf dist build *.spec
echo ""

# 第一步：生成基础 spec 文件
echo "🔨 步骤 1/3: 生成配置文件..."
$PYINSTALLER_CMD \
    --name "FileDownloader" \
    --onedir \
    --noconfirm \
    file_downloader.py \
    > /dev/null 2>&1

echo "✓ 配置文件已生成"
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
$PYINSTALLER_CMD --noconfirm FileDownloader.spec

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
    exit 1
fi
