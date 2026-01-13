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

### 方法一：标准打包（推荐）

最简单的方式，适合大多数用户：

```bash
# GUI 模式（无终端窗口）
./build-macos.sh gui

# 控制台模式（有终端窗口，便于调试）
./build-macos.sh console

# 清理构建文件
./build-macos.sh clean
```

### 方法二：高级打包（最佳实践）

使用 spec 文件进行精细控制，获得更好的优化：

```bash
# 使用优化的 spec 文件打包
./build-macos-advanced.sh
```

**高级打包的优势**：
- ✅ Universal Binary（同时支持 Intel 和 Apple Silicon）
- ✅ 排除不必要的模块，体积更小
- ✅ 更好的元数据和系统集成
- ✅ 支持暗黑模式
- ✅ 可自定义图标和版本信息

### 方法三：手动打包

如果需要完全自定义：

```bash
# 1. 安装依赖
pip3 install -r requirements-macos.txt

# 2a. 使用命令行参数（快速）
pyinstaller --name "FileDownloader" --noconfirm file_downloader.py

# 2b. 使用 spec 文件（推荐）
pyinstaller --noconfirm FileDownloader-macos.spec
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

### macOS 最佳实践说明

✅ **推荐**：
- 不使用 `--onefile`（.app bundle 本身就是独立包）
- 不使用 `--windowed`（用默认的 GUI 模式）
- 使用 `--noconfirm` 自动覆盖
- 使用 spec 文件进行精细控制
- 不使用 UPX 压缩（macOS 不推荐）
- 支持 Universal Binary

❌ **避免**：
- `--onefile` + GUI 模式（会导致启动慢、体积大）
- `--upx`（可能导致 macOS Gatekeeper 问题）
- `--strip`（会移除必要的调试信息）
