import os
import json
import yaml
from pathlib import Path
from tabulate import tabulate

def read_text_fallback(path, encodings=['utf-8', 'gbk', 'latin-1']):
    """
    尝试多种编码读取文件，避免 UnicodeDecodeError
    """
    for enc in encodings:
        try:
            with open(path, 'r', encoding=enc) as f:
                return f.read()
        except UnicodeDecodeError:
            continue
    raise UnicodeDecodeError(f"Unable to decode {path} with {encodings}")

# 获取上一级目录
parent_dir = Path(__file__).parent.parent

# 🔗 设置你的 GitHub 仓库 URL（比如 main 分支）
GITHUB_BASE_URL = "https://github.com/wuwweizn/wwzn-china/blob/main/"

# 初始化结果列表
results = []

# 遍历上一级目录的所有子目录
for subdir in parent_dir.iterdir():
    if subdir.is_dir():
        # 查找 config 文件
        config_files = list(subdir.glob('config.[jJ][sS][oO][nN]')) + list(subdir.glob('config.[yY][aA][mM][lL]'))
        
        for config_file in config_files:
            try:
                # 读取配置文件（自动尝试不同编码）
                text = read_text_fallback(config_file)

                # 解析内容
                if config_file.suffix.lower() == '.json':
                    config = json.loads(text)
                else:
                    config = yaml.safe_load(text)
                
                # 提取所需字段
                name = config.get('name', 'N/A')
                description = config.get('description', 'N/A')
                version = config.get('version', 'N/A')
                
                # 计算相对路径
                relative_path = config_file.relative_to(parent_dir).as_posix()
                
                # 生成 GitHub 链接
                github_link = f"[{relative_path}]({GITHUB_BASE_URL}{relative_path})"
                
                # 添加到结果列表
                results.append([name, description, version, github_link])
                
            except Exception as e:
                print(f"Error parsing {config_file}: {e}")
                continue

# 生成 Markdown 表格
headers = ['Name', 'Description', 'Version', 'Config Path']
markdown_table = tabulate(results, headers, tablefmt='github')

# 写入 DOCS.md
output_file = parent_dir / "88wwzn88" / "DOCS.md"
output_file.parent.mkdir(exist_ok=True, parents=True)  # 确保目录存在

with open(output_file, 'w', encoding='utf-8') as f:
    f.write("# Configuration Summary\n\n")
    f.write(markdown_table)
