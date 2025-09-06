# V2Ray Core Home Assistant Add-on

## 概述

这是一个基于 V2Ray Core 的 Home Assistant 加载项，用于在 Home Assistant 环境中运行 V2Ray 代理服务。

## 配置

-【订阅连接配置】 subscription_url: https://wuwweizn.com

-【手动节点选择】 selected_node：1-30(填入节点序号，日志中查看节点信息)

-【节点轮询模式】 enable_node_selection：开或关

其他默认

## 使用说明(请查阅使用文档)

1. 启动加载项后，V2Ray 将监听配置文件中指定的端口
2. 默认配置下：
   - SOCKS5 代理端口：10808
   - HTTP 代理端口：10809
3. 你可以在其他应用中配置这些代理设置来使用 V2Ray

## 支持的架构

- amd64
- aarch64 (ARM64)
- armv7

### 查看日志
- 在 Home Assistant 的 Supervisor > V2Ray Core 中查看日志

### 常见问题

1. **加载项无法启动**
   - 检查订阅链接是否有效
   - 确认端口没有被其他服务占用
   - 查看日志获取详细错误信息

2. **订阅解析失败**
   - 确认订阅链接格式正确
   - 检查网络连接是否正常
   - 验证订阅内容是否包含支持的协议

3. **代理连接失败**
   - 确认服务器节点状态
   - 检查防火墙设置
   - 验证代理端口配置

4. **订阅不自动更新**
   - 确认 `auto_start` 设置为 true
   - 检查 `update_interval` 设置
   - 查看日志中的更新信息

## 参考链接

- [V2Ray 官方文档](https://www.v2fly.org/)
- [V2Ray Core GitHub](https://github.com/v2fly/v2ray-core)
- [Home Assistant Add-on 开发文档](https://developers.home-assistant.io/docs/add-ons/)