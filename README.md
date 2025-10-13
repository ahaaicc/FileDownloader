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

## 打包为单文件 EXE

```bash
# 生成单文件 EXE（保留控制台窗口，自动使用环境变量中的 UPX）
pyinstaller --onefile --console file_downloader.py
```

- 输出文件位置：`dist/file_downloader.exe`
- **UPX 使用条件**：
  - 若已将 UPX 添加到系统 PATH（如 `C:\\upx`），无需额外参数
  - 若未添加 PATH，请使用 `--upx-dir="C:\\upx"` 指定路径
