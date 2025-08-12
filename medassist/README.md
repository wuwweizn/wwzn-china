＃家庭助理插件：MedAssist

MedAssist是一个简单的Node.js应用程序，用爱来帮助我的伴侣管理他们的日常药物。
通过发送提醒，可以轻松跟踪药物清单和重新订购。
如果您不确定是否服用剂量，只需检查仪表板，然后将预期库存与实际数量进行比较可以帮助确认。
对于旅行，MedAssist通过在您离开的时间内快速清单来消除压力。

##功能
如果您定期服用至少一种药物，则此应用程序可能很有用。
但是，如果您使用复杂的时间表管理多种药物，您可能会更喜欢它。
- 跟踪药物清单，并确切知道何时重新订购 
- 在供应较低时收到电子邮件提醒 
- 生成旅行的自定义药物列表，包括您选择的时间范围所需的数量（通过电子邮件可选） 
- 简单的仪表板显示药物状态和即将到来的时间表 
- 以用户友好的网络界面 - 用于用户友好的网络界面，以实现易药物管理和配置管理和配置管理和配置管理和配置，


_Thanks to everyone having starred my repo! To star it click on the image below, then it will be on top right. Thanks!_

[![Stargazers repo roster for @jdeath/homeassistant-addons](https://reporoster.com/stars/jdeath/homeassistant-addons)](https://github.com/jdeath/homeassistant-addons/stargazers)

##关于
此插件使用[Docker Image]（https://github.com/njic/medassist/releases）。
 ##安装
此附加组件的安装非常简单，与安装任何其他Hass.io附加组件相比并没有什么不同。

1.[将我的hass.io附加存储库添加] [存储库]到您的hass.io实例。
2.单击“保存”按钮以存储您的配置。
3.启动附加组件。
4.检查附加组件的日志，以查看一切是否进展顺利。
5.打开webui应通过<your-ip>：端口
6.设置将在 /addon_configs /2effc9b9_medassist

 ##配置

```
port : 3111 #port you want to run on.
```

Webui can be found at `<your-ip>:port`.

[repository]: https://github.com/jdeath/homeassistant-addons
