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
4. 安装完成后前往 **配置** 页填写 TMDB 参数（可选），点击 **启动**
5. 浏览器访问 `http://<your-ha-ip>:17380`

---

## HA 配置页说明

> HA 配置页**只有以下 3 项**是真正有效的运行时配置，修改后重启加载项即生效。
> 视频源、访问密码等均需在**应用界面内**设置，HA 配置页不提供这些选项。

| 配置项 | 默认值 | 说明 |
|---|---|---|
| `oki_tmdb_api_token` | 空 | TMDB API Token，填写后启用「TMDB 智能模式」（封面、评分、推荐） |
| `oki_tmdb_api_base_url` | `https://api.tmdb.org/3` | TMDB API 地址，中国大陆保持默认即可 |
| `oki_tmdb_image_base_url` | `https://image.tmdb.org/t/p/` | TMDB 图片地址，中国大陆保持默认即可 |

---

## 视频源配置（重要）

> ⚠️ 视频源必须在**应用界面内**添加，HA 配置页填写的源地址**不会生效**。

OuonnkiTV 使用的是**苹果CMS / 程序猫**等影视聚合 API，**不是普通视频网站地址**。

### 视频源 JSON 格式

```json
[
  {
    "name": "源名称",
    "url": "https://api.example.com/api.php/provide/vod",
    "isEnabled": true
  }
]
```

### 添加视频源步骤

1. 打开应用 → 右上角 **设置图标**
2. 进入 **视频源** → 点击 **导入源**
3. 选择「JSON 文本导入」，粘贴上方格式的内容
4. 点击「开始导入」

### 在哪里找视频源

可以在以下地方搜索公开的苹果CMS API 源：

- 搜索关键词：`苹果CMS API接口` / `影视源 api.php/provide/vod`
- GitHub 上搜索：`LibreTV sources` / `影视聚合源`
- 各影视自建站通常提供公开 API（URL 以 `/api.php/provide/vod` 结尾）

---

## TMDB 智能模式

启用后可自动匹配影片封面、评分、简介和推荐内容。

**申请 Token：**
1. 注册 [themoviedb.org](https://www.themoviedb.org/) 账号
2. 进入 [API 设置页](https://www.themoviedb.org/settings/api) 申请 **Read Access Token**
3. 将 Token 填入 HA 配置页的 `oki_tmdb_api_token`，重启加载项

> 详细步骤见上游文档：[tmdb-key.md](https://github.com/Ouonnki/OuonnkiTV/blob/main/docs/tmdb-key.md)

---

## 其他应用内设置

以下配置均在应用界面内操作，与 HA 配置页无关：

- **访问密码**：设置 → 系统设置 → 访问密码
- **TMDB 内容语言**：设置 → 系统设置（支持简体中文、繁体、English、日本語）
- **导出/导入个人配置**：设置 → 关于项目 → 配置操作（可备份全部设置）

---

## 端口

| 端口 | 说明 |
|---|---|
| `17380/tcp` | Web UI 访问端口 |

## 支持架构

`amd64` / `aarch64`（ARM64）/ `armv7`（ARM 32位）