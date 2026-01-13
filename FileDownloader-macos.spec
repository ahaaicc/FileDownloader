# -*- mode: python ; coding: utf-8 -*-
# macOS 优化的 PyInstaller 配置文件
# 使用方法: pyinstaller FileDownloader-macos.spec

import sys
from PyInstaller.utils.hooks import collect_data_files

# 应用元数据
APP_NAME = 'FileDownloader'
BUNDLE_IDENTIFIER = 'com.filedownloader.app'
VERSION = '1.0.0'

# 分析阶段 - 收集所有依赖
a = Analysis(
    ['file_downloader.py'],
    pathex=[],
    binaries=[],
    datas=[],
    hiddenimports=[
        # 明确声明隐藏导入，避免运行时错误
        'tkinter',
        'tkinter.ttk',
        'tkinter.filedialog',
        'requests',
        'urllib3',
        'certifi',
        'charset_normalizer',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        # 排除不需要的模块以减小体积
        'matplotlib',
        'numpy',
        'pandas',
        'scipy',
        'PIL',
        'PyQt5',
        'PyQt6',
        'PySide2',
        'PySide6',
        'wx',
    ],
    noarchive=False,
    optimize=0,  # 0=无优化, 1=基础优化, 2=移除 docstrings
)

# 打包 Python 字节码
pyz = PYZ(a.pure)

# 创建可执行文件
exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name=APP_NAME,
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,  # 不 strip 符号，保留调试信息
    upx=False,    # macOS 上不推荐使用 UPX
    console=False,  # GUI 模式，不显示控制台
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch='universal2',  # 支持 Intel 和 Apple Silicon
    codesign_identity=None,  # 代码签名（留空表示不签名）
    entitlements_file=None,
)

# 收集所有文件
coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=False,
    upx_exclude=[],
    name=APP_NAME,
)

# 创建 macOS .app bundle
app = BUNDLE(
    coll,
    name=f'{APP_NAME}.app',
    icon=None,  # 如果有图标文件，在这里指定: 'icon.icns'
    bundle_identifier=BUNDLE_IDENTIFIER,
    version=VERSION,
    info_plist={
        'CFBundleName': APP_NAME,
        'CFBundleDisplayName': 'File Downloader',
        'CFBundleVersion': VERSION,
        'CFBundleShortVersionString': VERSION,
        'NSHighResolutionCapable': True,
        'NSRequiresAquaSystemAppearance': False,  # 支持暗黑模式
        'LSMinimumSystemVersion': '10.13.0',  # 最低系统版本
        'NSHumanReadableCopyright': 'Copyright © 2026',
    },
)
