# OuonnkiTV

一键搭建个人影视站，支持 TMDB 智能模式，基于 LibreTV 修改。

> 上游项目：[Ouonnki/OuonnkiTV](https://github.com/Ouonnki/OuonnkiTV)

---

## 安装

1. 在 Home Assistant 中进入 **设置 → 加载项 → 加载项商店**
2. 点击右上角菜单 → **仓库** → 添加：
   ```
   https://github.com/wuwweizn/wwzn-china
   ```
3. 刷新页面后搜索 **OuonnkiTV**，点击安装
4. 安装完成后前往 **配置** 页填写参数，再点击 **启动**
5. 浏览器访问 `http://<your-ha-ip>:17380`

---

## 配置项说明

> ⚠️ 所有配置项均在**镜像构建时**注入（Vite 编译打包），修改配置后需重新构建镜像并重启加载项才能生效。  
> 如果只是临时调整视频源，建议直接在应用内手动添加，无需重建。

| 配置项 | 默认值 | 说明 |
|---|---|---|
| `oki_initial_video_sources` | 空 | 预置视频源，支持 JSON 字符串或远程 URL（见下方示例） |
| `oki_tmdb_api_token` | 空 | TMDB API Token，填写后启用「TMDB 智能模式」（封面、评分、推荐等） |
| `oki_tmdb_api_base_url` | `https://api.tmdb.org/3` | TMDB API 地址，中国大陆推荐使用默认值 `https://api.tmdb.org/3` |
| `oki_tmdb_image_base_url` | `https://image.tmdb.org/t/p/` | TMDB 图片地址，中国大陆推荐使用默认值 `https://image.tmdb.org/t/p/` |
| `oki_access_password` | 空 | 访问密码，留空则无需密码直接访问 |
| `oki_disable_analytics` | `true` | 禁用 Vercel Analytics 统计（非 Vercel 部署建议保持 `true`） |
| `oki_initial_config` | 空 | 完整配置 JSON（优先级最高，见下方说明） |

---

## 配置方式详解

### 方式一：预置视频源 `oki_initial_video_sources`

支持两种格式：

**JSON 字符串：**
```json
[{"name":"示例源","url":"https://api.example.com","isEnabled":true}]
```

**远程 URL（自动拉取 JSON 文件）：**
```
https://example.com/my-sources.json
```

> 视频源格式详见上游文档：[video-sources.md](https://github.com/Ouonnki/OuonnkiTV/blob/main/docs/video-sources.md)

---

### 方式二：完整配置导入 `oki_initial_config`（推荐）

这是最强大的预置方式，可以一次性导入所有设置和视频源。

**操作步骤：**

1. 先启动一次加载项（使用默认配置）
2. 在应用内完成所有配置（添加视频源、设置 TMDB Token、调整偏好等）
3. 进入 **设置 → 关于项目 → 配置操作 → 导出个人配置 → 导出为文本**
4. 将复制的 JSON 内容粘贴到 `oki_initial_config` 配置项中
5. 重新触发镜像构建，拉取新镜像后重启加载项

> `oki_initial_config` 的优先级高于 `oki_initial_video_sources` 及其他单项配置。

---

### TMDB 智能模式

启用后可自动匹配影片元数据、海报、评分和推荐内容，显著提升浏览体验。

**申请 Token：**
1. 注册 [themoviedb.org](https://www.themoviedb.org/) 账号
2. 进入 [API 设置页](https://www.themoviedb.org/settings/api) 申请 API Token（Read Access Token）
3. 将 Token 填入 `oki_tmdb_api_token`

> 详细申请步骤见上游文档：[tmdb-key.md](https://github.com/Ouonnki/OuonnkiTV/blob/main/docs/tmdb-key.md)

---

## 更新镜像

修改配置后，按以下步骤重建并应用新镜像：

1. 前往 [GitHub Actions](https://github.com/wuwweizn/wwzn-china/actions)
2. 选择 **Build and Push OuonnkiTV** → **Run workflow**
3. 等待构建完成（约 5 分钟）
4. 回到 HA 加载项页面，停止加载项 → 重新启动（会自动拉取最新镜像）

---

## 端口

| 端口 | 说明 |
|---|---|
| `17380/tcp` | Web UI 访问端口 |

---

## 支持架构

| 架构 | 说明 |
|---|---|
| `amd64` | x86_64 主机 |
| `aarch64` | ARM64（树莓派 4/5、部分 NAS） |
| `armv7` | ARM 32位（树莓派 2/3） |
