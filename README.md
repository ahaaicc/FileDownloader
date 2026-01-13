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

### 方法一：使用自动化脚本（推荐）

```bash
# 赋予脚本执行权限
chmod +x build-macos.sh

# 运行脚本自动完成打包
./build-macos.sh
```

### 方法二：手动打包

```bash
# 1. 安装 macOS 专用依赖
pip install -r requirements-macos.txt

# 2. 打包为 .app（推荐，不弹出终端窗口）
pyinstaller --windowed --name "FileDownloader" file_downloader.py

# 或打包为控制台应用（弹出终端窗口，便于调试）
pyinstaller --console --name "FileDownloader" file_downloader.py
```

> **注意**：macOS 不推荐使用 `--onefile` 参数，因为 .app bundle 本身就是独立应用包

- **输出位置**：`dist/FileDownloader.app`
- **运行方式**：
  1. 双击运行：直接双击 `dist/FileDownloader.app`
  2. 终端运行（可查看日志）：
     ```bash
     ./dist/FileDownloader.app/Contents/MacOS/FileDownloader
     ```
- **应用大小**：约 30-40 MB（包含所有依赖）
- **使用 spec 文件打包**：
  ```bash
  pyinstaller FileDownloader.spec
  ```
