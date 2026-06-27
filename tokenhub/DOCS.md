# HACS Token Hub 使用说明

自托管 GitHub Token 共享池，为 HACS 极速版提供共享令牌服务。

## 为什么需要这个加载项？

官方的 `tokenhub.hacs.vip` 共享令牌服务因服务器 TLS 证书配置问题，可能导致 HACS 极速版无法获取共享令牌。
本加载项在你自己的 Home Assistant 上搭建一个完全相同的服务，完全自主可控。

## 安装步骤

1. 安装并启动本加载项
2. 打开侧边栏的 **Token Hub** 面板（或访问 `http://HA地址:8765`）
3. 粘贴你的 GitHub Personal Access Token 并点击添加
4. 在 HACS 集成选项中，将「共享令牌服务器地址」设置为：
   ```
   http://homeassistant.local:8765
   ```
   （或使用你的 HA IP 地址）
5. 重新配置 HACS 集成，勾选「使用共享令牌」即可

## 如何获取 GitHub Personal Access Token

1. 打开 [github.com/settings/tokens](https://github.com/settings/tokens)
2. 点击 **Generate new token (classic)**
3. Note 随便填写，Expiration 选择 **No expiration**
4. 勾选 **repo** 权限
5. 点击 **Generate token**，复制生成的 `ghp_xxx...` 字符串

## Token 管理

- **添加**：在 Web 界面粘贴 Token 后点击添加，会自动验证有效性
- **刷新**：点击刷新按钮更新 Token 的剩余 API 配额信息
- **删除**：点击删除按钮移除失效的 Token

## 数据持久化

Token 数据保存在 `/data/tokens.db`（SQLite），重启加载项不会丢失数据。

## 网络说明

本加载项通过 `ghapi.hacs.vip`（大陆可访问的 GitHub API 代理）验证 Token，
无需直连 `api.github.com`，完全适合大陆网络环境。
