# XRay Home Assistant Add-on

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armv7 Architecture][armv7-shield]

XRay是一个网络代理平台，可以帮助您绕过网络限制。

## 关于

XRay是XTLS项目的核心组件，提供了强大的代理功能，支持多种协议。这个Home Assistant加载项将XRay打包为一个易于使用的服务。

## 功能特性

- 支持SOCKS和HTTP代理协议
- 多架构支持（amd64, aarch64, armv7）
- 可配置的日志级别
- 自动配置文件验证
- 支持自定义配置文件

## 安装

1. 在Home Assistant中添加此存储库：
   ```
   https://github.com/wuwweizn/wwzn-china
   ```

2. 从Add-on Store安装XRay加载项

3. 启动加载项

## 配置

### 选项

| 选项 | 描述 | 默认值 |
|------|------|--------|
| `log_level` | 日志级别 (debug/info/warning/error/none) | `warning` |
| `config_file` | 配置文件路径 | `/data/config/config.json` |

### 默认端口

- **10808**: SOCKS代理端口
- **10809**: HTTP代理端口

## 使用方法

1. 启动加载项后，会自动创建默认配置文件
2. 您可以通过修改 `/config/xray/config.json` 来自定义配置
3. 重启加载项以应用新配置

### 示例配置

```json
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 10808,
      "protocol": "socks",
      "settings": {
        "auth": "noauth",
        "udp": true
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
```

## 故障排除

1. 检查配置文件语法是否正确
2. 查看加载项日志获取错误信息
3. 确保端口没有被其他服务占用

## 支持

如果您遇到问题，请在GitHub仓库中创建issue：
https://github.com/wuwweizn/wwzn-china/issues

## 许可证

本项目基于MPL-2.0许可证。

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg