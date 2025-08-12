# Home assistant add-on: xTeVe

[![Donate][donation-badge]](https://www.buymeacoffee.com/alexbelgium)
[![Donate][paypal-badge]](https://www.paypal.com/donate/?hosted_button_id=DZFULJZTP3UQA)

![Version](https://img.shields.io/badge/dynamic/json?label=Version&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2Falexbelgium%2Fhassio-addons%2Fmaster%2Fxteve%2Fconfig.json)
![Ingress](https://img.shields.io/badge/dynamic/json?label=Ingress&query=%24.ingress&url=https%3A%2F%2Fraw.githubusercontent.com%2Falexbelgium%2Fhassio-addons%2Fmaster%2Fxteve%2Fconfig.json)
![Arch](https://img.shields.io/badge/dynamic/json?color=success&label=Arch&query=%24.arch&url=https%3A%2F%2Fraw.githubusercontent.com%2Falexbelgium%2Fhassio-addons%2Fmaster%2Fxteve%2Fconfig.json)

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/9c6cf10bdbba45ecb202d7f579b5be0e)](https://www.codacy.com/gh/alexbelgium/hassio-addons/dashboard?utm_source=github.com&utm_medium=referral&utm_content=alexbelgium/hassio-addons&utm_campaign=Badge_Grade)
[![GitHub Super-Linter](https://img.shields.io/github/actions/workflow/status/alexbelgium/hassio-addons/weekly-supelinter.yaml?label=Lint%20code%20base)](https://github.com/alexbelgium/hassio-addons/actions/workflows/weekly-supelinter.yaml)
[![Builder](https://img.shields.io/github/actions/workflow/status/alexbelgium/hassio-addons/onpush_builder.yaml?label=Builder)](https://github.com/alexbelgium/hassio-addons/actions/workflows/onpush_builder.yaml)

[donation-badge]: https://img.shields.io/badge/Buy%20me%20a%20coffee%20(no%20paypal)-%23d32f2f?logo=buy-me-a-coffee&style=flat&logoColor=white
[paypal-badge]: https://img.shields.io/badge/Buy%20me%20a%20coffee%20with%20Paypal-0070BA?logo=paypal&style=flat&logoColor=white

_Thanks to everyone having starred my repo! To star it click on the image below, then it will be on top right. Thanks!_

[![Stargazers repo roster for @alexbelgium/hassio-addons](https://raw.githubusercontent.com/alexbelgium/hassio-addons/master/.github/stars2.svg)](https://github.com/alexbelgium/hassio-addons/stargazers)

![downloads evolution](https://raw.githubusercontent.com/alexbelgium/hassio-addons/master/xteve/stats.png)

##关于
Plex DVR和Emby Live TV的M3U代理。
项目主页：https：//github.com/xteve-project/xteve
基于docker映像：https：//hub.docker.com/r/collelog/xteve 

## Installation

The installation of this add-on is pretty straightforward and not different in
comparison to installing any other Hass.io add-on.

1. [Add my Hass.io add-ons repository][repository] to your Hass.io instance.
1. Install this add-on.
1. Click the `Save` button to store your configuration.
1. Start the add-on.
1. Check the logs of the add-on to see if everything went well.
1. Carefully configure the add-on to your preferences, see the official documentation for for that.
##安装
此附加组件的安装非常简单，并且与安装任何其他Hass.io Add-Ond-on相比，这是非常简单的，并且没有什么不同。
1.[将我的hass.io附加存储库添加] [存储库]到您的hass.io实例。 
2.安装此附加组件。 
3.单击“保存”按钮以存储您的配置。 
4.启动附加组件。 
5.检查附加组件的日志，以查看一切是否进展顺利。 
6.仔细地将附加组件配置为您的首选项，请参阅官方文档。

##配置
WebUI可以在<http：// homeassistant：34400/web>上找到。
由于大多数设置是通过Web界面配置的，因此此附件具有最小的配置选项。

 ###选项
此插件不需要配置选项。所有配置都是通过端口34400的Web界面完成的。

###示例配置


```yaml
# 无需选项 - 通过Web界面配置
```

**Note**: xTeVe stores its configuration in `/data/` and runs on port 34400. Access the web interface to configure M3U playlists and XMLTV sources.

##支持
在github [存储库]上创建问题：https：//github.com/alexbelgium/hassio-addons