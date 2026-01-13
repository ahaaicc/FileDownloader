# FileDownloader

### Try the following links:
```
https://ambientcg.com/get?file=Gravel041_1K-JPG.zip
https://ambientcg.com/get?file=Gravel042_1K-JPG.zip
https://ambientcg.com/get?file=Gravel040_1K-JPG.zip
https://ambientcg.com/get?file=Gravel023_1K-JPG.zip
https://ambientcg.com/get?file=Gravel022_1K-JPG.zip
https://ambientcg.com/get?file=Gravel026_1K-JPG.zip
https://ambientcg.com/get?file=Gravel024_1K-JPG.zip
https://ambientcg.com/get?file=Gravel038_1K-JPG.zip
https://ambientcg.com/get?file=Gravel032_1K-JPG.zip
https://ambientcg.com/get?file=Gravel039_1K-JPG.zip
https://ambientcg.com/get?file=Gravel020_1K-JPG.zip
https://ambientcg.com/get?file=Gravel037_1K-JPG.zip
https://ambientcg.com/get?file=Gravel035_1K-JPG.zip
https://ambientcg.com/get?file=Gravel033_1K-JPG.zip

```

### 使用场景
1. 下载大量文件，如游戏场景的材质贴图、模型、hdr 等等
2. 结合 [八爪鱼采集器](https://www.bazhuayu.com/) 一起使用可以极大提高效率
3. 复制采集好的下载链接粘贴到输入框，点击下载，等待下载完成

## 依赖安装

### Windows
```bash
pip install -r requirements.txt
```

### macOS
```bash
pip install -r requirements-macos.txt
```

> **注意**：
> - Windows 和 macOS 使用不同的依赖文件，因为某些依赖是平台特定的
> - macOS 版本支持 Python 3.8+ （包括最新的 3.14）
> - 如果使用 Python 3.14+，会自动安装兼容版本的 PyInstaller (6.15+)

## 打包为单文件 EXE

```bash
# 生成单文件 EXE（保留控制台窗口，自动使用环境变量中的 UPX）
pyinstaller --onefile --console file_downloader.py
```

- 输出文件位置：`dist/file_downloader.exe`
- **UPX 使用条件**：
  - 若已将 UPX 添加到系统 PATH（如 `C:\\upx`），无需额外参数
  - 若未添加 PATH，请使用 `--upx-dir="C:\\upx"` 指定路径

## 打包为 macOS 独立运行应用（.app）

### 方法一：标准打包（推荐 ⭐）

**动态打包，自动检测依赖，长期稳定**

```bash
# GUI 模式（无终端窗口，默认）
./build-macos.sh

# 或显式指定模式
./build-macos.sh gui       # GUI 模式
./build-macos.sh console   # 控制台模式（调试用）
./build-macos.sh clean     # 清理构建文件
```

**特点**：
- ✅ 不依赖 spec 文件，不会过时
- ✅ PyInstaller 自动检测所有依赖
- ✅ 自动适配系统架构（Intel/Apple Silicon）
- ✅ 简单稳定，推荐日常使用

### 方法二：高级打包（可选）

使用 spec 文件进行精细控制，适合需要高度定制的场景：

```bash
# 使用预配置的 spec 文件打包
./build-macos-advanced.sh
```

**额外优势**：
- ✅ Universal Binary（同时支持 Intel 和 Apple Silicon）
- ✅ 排除不必要的模块，体积更小
- ✅ 自定义 bundle 元数据
- ✅ 可配置图标、版本号等

**注意**：spec 文件需要手动维护，添加新依赖时需要更新配置。

### 方法三：手动打包

如果你熟悉 PyInstaller，可以直接使用命令行：

```bash
# 1. 安装依赖
pip3 install -r requirements-macos.txt

# 2. 打包（自动生成 .app）
pyinstaller --name "FileDownloader" --onedir --noconfirm file_downloader.py
```

### 打包输出

- **位置**：`dist/FileDownloader.app`
- **大小**：约 30-40 MB
- **架构**：Universal (Intel + Apple Silicon)

### 运行方式

```bash
# 方式1：双击运行
open dist/FileDownloader.app

# 方式2：终端运行（查看日志）
./dist/FileDownloader.app/Contents/MacOS/FileDownloader

# 方式3：安装到系统
cp -r dist/FileDownloader.app /Applications/
```

### 两种打包方式对比

| 特性 | 标准打包 | 高级打包 |
|-----|---------|---------|
| **稳定性** | ⭐⭐⭐⭐⭐ 不会过时 | ⭐⭐⭐ 需要维护 spec |
| **易用性** | ⭐⭐⭐⭐⭐ 一键打包 | ⭐⭐⭐ 需要了解配置 |
| **体积** | 正常 (~35MB) | 略小 (~30MB) |
| **架构** | 自动检测 | Universal Binary |
| **依赖检测** | 自动 | 手动配置 |
| **推荐场景** | 日常使用 | 生产发布 |

### macOS 打包最佳实践

✅ **推荐做法**：
- 使用 `--onedir` 而非 `--onefile`（启动更快，兼容性更好）
- 使用 `--noupx`（避免 macOS Gatekeeper 问题）
- 让 PyInstaller 自动检测依赖（比手动维护更可靠）
- 不使用 `--strip`（保留调试信息）

❌ **避免做法**：
- `--onefile` 在 macOS 上会导致启动慢、临时文件问题
- `--upx` 可能触发安全警告
- 过度优化（如 `optimize=2`）可能导致运行时错误
