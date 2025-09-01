FRP Client 1.26.0

## 关于

您可以使用此工具通过端口转发实现对本地Home Assistant操作系统的远程访问。


## 配置说明

1、 按照实际情况填写相关"配置",自定义二级域名必填。

2、 用File editor修改Home Assistant `configuration.yaml` 最后一行添加：

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 127.0.0.1
```
3、 修改之后，重启HA

4、配置页面
server_addr：frp服务器地址
server_port:   frp服务器端口号
token: 服务器端设置的密钥
proxy_type: 一般选tcp .选http时，必须填写下面的custom_domains
proxy_name: 自定义你的ha名称
local_port: ha端口号8123
custom_domains: 自定义二级域名
remote_port: 外网访问ha端口

## 本项目为Frp HA客户端

https://github.com/huxiaoxu2019/hass-addon-frp-client