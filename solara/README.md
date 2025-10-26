# Solara 配置示例

## 基本配置

在 Home Assistant 加载项的 "配置" 选项卡中，使用以下 YAML 格式：

```yaml
api_url: https://music-api.gdstudio.xyz
log_level: info
```

## 配置选项说明

### api_url (必需)

API 后端地址，用于搜索和播放音乐。

**选项 1: 使用 GD音乐台官方API（默认，推荐）**
```yaml
api_url: https://music-api.gdstudio.xyz
```


**重要提示**：
- URL 不要以斜杠 `/` 结尾
- 必须使用 `https://` 协议
- 确保域名可以从你的 Home Assistant 访问

### log_level (可选)

日志详细程度，用于调试。

```yaml
log_level: info  # 可选: debug, info, warning, error
```

- `debug`: 最详细，包含所有调试信息
- `info`: 标准信息（推荐）
- `warning`: 只显示警告和错误
- `error`: 只显示错误

## 完整配置示例

```yaml
api_url: https://music-api.gdstudio.xyz
log_level: info
```

## 如何修改配置

1. 在 Home Assistant 中打开 Solara 加载项
2. 点击 "配置" 选项卡
3. 编辑 YAML 配置
4. 点击 "保存"
5. 重启加载项（点击 "重启"）

## 验证配置

修改配置后，检查日志确认：

```
[INFO] API URL: https://music.miaowu086.online
[INFO] API URL configured successfully
```

## 使用自己的 Cloudflare Pages

### 步骤 1: 部署到 Cloudflare Pages

1. Fork https://github.com/akudamatata/Solara
2. 登录 Cloudflare Dashboard
3. Workers & Pages > Create application > Pages
4. 连接你的 GitHub 仓库
5. 部署设置：
   - Build command: (留空)
   - Build output directory: `/`
6. 保存并部署

### 步骤 2: 获取域名

部署完成后，Cloudflare 会分配一个域名，例如：
```
https://solara-abc123.pages.dev
```

### 步骤 3: 更新配置

在 Home Assistant 加载项配置中：

```yaml
api_url: https://solara-abc123.pages.dev
log_level: info
```

### 步骤 4: 重启加载项

保存配置并重启加载项。

## 故障排查

### 问题：搜索不到歌曲

**检查 1**: 确认 API URL 配置正确
```bash
# 在浏览器中访问
https://你的域名/
```
应该能看到 Solara 页面。

**检查 2**: 查看加载项日志
```
[INFO] API URL: https://...
[INFO] API URL configured successfully
```

**检查 3**: 打开浏览器控制台 (F12)
- 查看是否有 CORS 错误
- 查看 Network 标签中的 API 请求

### 问题：CORS 错误

如果看到跨域错误，说明：
- API 后端没有正确配置 CORS
- 使用的不是正确的 Cloudflare Pages 部署

**解决方法**：确保使用完整部署的 Cloudflare Pages（包含 Functions）

### 问题：API URL 不生效

**可能原因**：
1. URL 格式错误（多了斜杠）
2. 没有重启加载项
3. /config/solara 中有旧的配置文件

**解决方法**：
```bash
# SSH 进入 Home Assistant
rm -rf /config/solara/*
# 然后重启加载项
```

## 高级配置

### 使用多个 API 源

如果想切换不同的 API 源，只需修改 `api_url` 并重启：

```yaml
# GD 音乐台官方API（推荐）
api_url: https://music-api.gdstudio.xyz

# 你的 Cloudflare Pages
api_url: https://music.miaowu086.online

# 其他来源
api_url: https://your-music-api.com
```

### 持久化自定义配置

如果你想完全自定义 Solara：

1. 复制配置到本地：
```bash
cd /config/solara
# 编辑 index.html 等文件
```

2. 禁用自动 API URL 替换：
- 手动编辑 `index.html` 中的 `API.baseUrl`
- 在配置中使用占位符（加载项会跳过替换）

3. 重启加载项时会使用你的自定义版本

## 测试配置

### 快速测试

访问加载项 Web UI：
1. 点击 "打开 Web UI"
2. 尝试搜索音乐（例如："周杰伦"）
3. 如果能看到结果，说明配置成功

### 完整测试

1. 搜索音乐 ✓
2. 播放音乐 ✓
3. 查看歌词 ✓
4. 下载音乐 ✓
5. 添加到播放列表 ✓

如果以上功能都正常，说明 API 配置完全正确！