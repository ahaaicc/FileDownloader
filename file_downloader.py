import tkinter as tk
from tkinter import ttk, filedialog
import requests
from pathlib import Path
import threading
from urllib.parse import unquote
import os
from urllib.parse import parse_qs, urlparse

class FileDownloader:
    def __init__(self):
        self.window = tk.Tk()
        self.window.title("文件批量下载器")
        self.window.geometry("600x400")
        
        # 创建界面元素
        self.create_widgets()
        
    def create_widgets(self):
        # 链接输入区
        self.url_frame = ttk.LabelFrame(self.window, text="下载链接")
        self.url_frame.pack(padx=10, pady=5, fill="both", expand=True)
        
        self.url_text = tk.Text(self.url_frame, height=10)
        self.url_text.pack(padx=5, pady=5, fill="both", expand=True)
        
        # 保存路径选择
        self.path_frame = ttk.Frame(self.window)
        self.path_frame.pack(padx=10, pady=5, fill="x")
        
        self.path_var = tk.StringVar()
        self.path_entry = ttk.Entry(self.path_frame, textvariable=self.path_var)
        self.path_entry.pack(side="left", fill="x", expand=True, padx=(0,5))
        
        self.browse_btn = ttk.Button(self.path_frame, text="选择保存位置", command=self.browse_path)
        self.browse_btn.pack(side="right")
        
        # 进度显示区
        self.progress_frame = ttk.LabelFrame(self.window, text="下载进度")
        self.progress_frame.pack(padx=10, pady=5, fill="x")
        
        self.progress_var = tk.StringVar(value="准备就绪")
        self.progress_label = ttk.Label(self.progress_frame, textvariable=self.progress_var)
        self.progress_label.pack(padx=5, pady=5)
        
        self.progress_bar = ttk.Progressbar(self.progress_frame, mode="determinate")
        self.progress_bar.pack(padx=5, pady=5, fill="x")
        
        # 下载按钮
        self.download_btn = ttk.Button(self.window, text="开始下载", command=self.start_download)
        self.download_btn.pack(pady=10)
        
    def browse_path(self):
        path = filedialog.askdirectory()
        if path:
            self.path_var.set(path)
            
    def download_file(self, url, save_path):
        try:
            # 添加请求头，模拟浏览器行为
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            }
            response = requests.get(url, stream=True, headers=headers, allow_redirects=True)
            response.raise_for_status()
            
            # 优先从 URL 的查询参数中获取文件名
            parsed_url = urlparse(url)
            query_params = parse_qs(parsed_url.query)
            filename = query_params.get('file', [None])[0]
            
            if not filename:
                # 从 Content-Disposition 获取文件名
                content_disposition = response.headers.get('content-disposition')
                if content_disposition and 'filename=' in content_disposition:
                    filename = content_disposition.split('filename=')[-1].strip('"')
                else:
                    # 从 URL 获取文件名，处理查询参数
                    url_path = url.split('?')[0]
                    filename = unquote(os.path.basename(url_path))
            
            # 确保文件名有效
            filename = "".join(c for c in filename if c.isprintable() and c not in r'<>:"/\|?*')
            
            # 处理文件名重复
            file_path = Path(save_path) / filename
            counter = 1
            while file_path.exists():
                name, ext = os.path.splitext(filename)
                file_path = Path(save_path) / f"{name}_{counter}{ext}"
                counter += 1
            
            # 获取文件大小
            total_size = int(response.headers.get('content-length', 0))
            
            # 下载并显示进度
            with open(file_path, 'wb') as f:
                downloaded = 0
                for chunk in response.iter_content(chunk_size=8192):
                    if chunk:
                        f.write(chunk)
                        downloaded += len(chunk)
                        progress = (downloaded / total_size) * 100 if total_size else 0
                        self.progress_bar["value"] = progress
                        self.progress_var.set(f"正在下载: {filename} ({progress:.1f}%)")
                        self.window.update_idletasks()
                        
            return True
        except Exception as e:
            self.progress_var.set(f"下载失败: {filename} - {str(e)}")
            return False
            
    def start_download(self):
        save_path = self.path_var.get()
        if not save_path:
            self.progress_var.set("请选择保存位置！")
            return
            
        urls = self.url_text.get("1.0", tk.END).strip().split('\n')
        urls = [url.strip() for url in urls if url.strip()]
        
        if not urls:
            self.progress_var.set("请输入下载链接！")
            return
            
        # 禁用按钮
        self.download_btn["state"] = "disabled"
        
        def download_thread():
            total = len(urls)
            success = 0
            
            for i, url in enumerate(urls, 1):
                self.progress_var.set(f"正在处理第 {i}/{total} 个文件")
                if self.download_file(url, save_path):
                    success += 1
                    
            self.progress_var.set(f"下载完成！成功: {success}/{total}")
            self.download_btn["state"] = "normal"
            self.progress_bar["value"] = 100
            
        # 在新线程中执行下载
        threading.Thread(target=download_thread, daemon=True).start()
        
    def run(self):
        self.window.mainloop()

if __name__ == "__main__":
    app = FileDownloader()
    app.run() 