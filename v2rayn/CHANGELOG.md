# 更新日志

所有此项目的重要更改都会记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
此项目遵循 [语义版本控制](https://semver.org/lang/zh-CN/)。

## [6.60] - 2024-12-07

### 新增
- 初始版本发布
- 支持多架构构建 (amd64, arm64, armv7)
- 集成 v2ray 和 xray 核心
- Web 管理界面
- HTTP 和 SOCKS5 代理支持
- 自动配置生成
- 路由规则支持
- DNS over HTTPS 支持
- 统计和监控功能
- 自动备份和恢复
- 健康检查机制

### 功能特性
- 支持 VMess, VLESS, Trojan, Shadowsocks 协议
- 流量嗅探和路由
- 局域网访问控制
- 日志管理
- 配置验证
- 性能优化

### 技术特性
- 基于 Alpine Linux
- S6 监督系统
- 多阶段 Docker 构建
- GitHub Actions 自动化
- 容器安全最佳实践

## [计划中] - 未来版本

### 计划新增
- 订阅链接支持
- 自动节点测速
- 图形化配置界面
- 更多协议支持
- 插件系统
- API 扩展

### 计划改进
- 性能优化
- 内存使用优化
- 启动速度提升
- 更好的错误处理
- 增强的日志系统