＃家庭助理插件：TasmOcompiler
TasmOcompiler是一个简单的Web GUI，可让您使用自己的设置编译出色的Tasmota固件
_Thanks to everyone having starred my repo! To star it click on the image below, then it will be on top right. Thanks!_

[![Stargazers repo roster for @jdeath/homeassistant-addons](https://reporoster.com/stars/jdeath/homeassistant-addons)](https://github.com/jdeath/homeassistant-addons/stargazers)

##关于
此插件的基于[Docker Image]（https://hub.docker.com/r/benzino777/tasmocompiler）

##安装

此附加组件的安装非常简单，与安装任何其他Hass.io附加组件相比并没有什么不同。

1.[将我的hass.io附加存储库添加] [存储库]到您的hass.io实例。
2.安装此附加组件。
3.单击“保存”按钮以存储您的配置。
4.启动附加组件。
5.检查附加组件的日志，以查看一切是否进展顺利。
6.转到本地IP：端口。入口因某种原因不起作用
7.请咨询官方文档以进行设置支持：https：//github.com/benzino7777/tasmocompiler

＃＃ 配置

```
port: 3000 # port you want to run frontend on
```

Webui can be found at `<your-ip>:port`.

[repository]: https://github.com/jdeath/homeassistant-addons
