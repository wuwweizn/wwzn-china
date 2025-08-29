
# DDNSTO Home Assistant Add-on

DDNSTO 动态域名解析服务集成，用于自动更新公网 IP 到 DDNSTO 平台，支持 Home Assistant 使用。

版本: 3.5.0  
兼容架构: amd64, aarch64  
镜像地址: ghcr.io/wuwweizn/ddnsto:3.5.0

---

## 功能

- 自动同步公网 IP 到 DDNSTO  
- 支持 Home Assistant 面板访问和管理  
- 多架构支持：amd64 / aarch64  

---

## 安装

### 通过 GitHub 仓库安装

1. 在 Home Assistant UI 中，进入 设置 → 加载项商店 → 添加自定义仓库  
2. 仓库地址填：  
   https://github.com/wuwweizn/wwzn-china  
3. 点击 “添加” 后搜索 `ddnsto`，安装即可  

### 镜像安装（高级）

在 HA Add-on 配置中直接使用镜像：

```

image: "ghcr.io/wuwweizn/ddnsto:3.5.0"

```

---

## 配置

在 Add-on 配置页面填写：

```

token: "你的 DDNSTO Token"

```

说明：token 是你在 DDNSTO 平台获取的授权码，用于更新域名解析。

---

## 使用说明

1. 启动 Add-on  
2. Add-on 会自动使用 token 更新公网 IP  
3. 可通过 Home Assistant 面板查看状态  

---

## 注意事项

- 确保 GHCR 镜像已存在并推送多架构 manifest  
- Home Assistant 版本需支持 `image` 字段拉远程镜像  
- 文件夹名和 slug 必须一致  

---

## 链接

GitHub 仓库: https://github.com/wuwweizn/wwzn-china  
DDNSTO 官方网站: https://www.ddnsto.com/
```

