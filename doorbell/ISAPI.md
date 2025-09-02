# Home Assistant 插件：Hikvision 门铃

## 常用 ISAPI 命令

```text
- GET /ISAPI/VideoIntercom/callStatus?format=json
  → 获取呼叫状态

- PUT /ISAPI/AccessControl/RemoteControl/door/1 <RemoteControlDoor><cmd>open</cmd></RemoteControlDoor>
  → 打开门铃继电器 1 对应的门

- PUT /ISAPI/System/reboot
  → 重启设备

- PUT /ISAPI/VideoIntercom/callSignal?format=json {"CallSignal":{"cmdType":"reject"}}
  → 拒绝来电

- GET /ISAPI/VideoIntercom/keyCfg/1
  → 获取门铃按键配置（编号 1）

- PUT /ISAPI/VideoIntercom/keyCfg/1 <KeyCfg><id>1</id><module>main</module><callNumber>1</callNumber><enableCallCenter>false</enableCallCenter><templateNo>1</templateNo></KeyCfg>
  → 设置按键配置（编号 1）

- PUT /ISAPI/SecurityCP/control/outputs/0?format=json {"OutputsCtrl":{"switch":"open"}}
  → 控制继电器输出打开

- POST /ISAPI/SecurityCP/status/outputStatus?format=json {"OutputCond":{"maxResults":2,"outputModuleNo":0,"searchID":"1","searchResultPosition":0}}
  → 获取继电器状态

- POST /ISAPI/AccessControl/UserInfo/Search?format=json {"UserInfoSearchCond":{"searchID":"1","searchResultPosition": 0,"maxResults": 10,"EmployeeNoList":[{"employeeNo":"6"}]}}
  → 查询用户信息

- POST /ISAPI/AccessControl/CardInfo/Search?format=json {"CardInfoSearchCond": {"searchID": "1","maxResults": 10,"searchResultPosition": 0,"EmployeeNoList": [{ "employeeNo": "6" }]}}
  → 查询门禁卡信息

- PUT /ISAPI/System/reboot
  → 重启设备（重复列出）

- GET /ISAPI/System/Audio/AudioOut/channels/1
  → 获取音频输出通道 1 的状态

- PUT /ISAPI/System/Audio/AudioOut/channels/1<AudioOut><id>1</id><AudioOutVolumelist><AudioOutVlome><type>audioOutput</type><volume>0</volume><talkVolume>7</talkVolume></AudioOutVlome></AudioOutVolumelist></AudioOut>
  → 设置音频输出音量及通话音量

- GET /ISAPI/System/IO/capabilities
  → 获取 I/O 功能列表

- GET /ISAPI/System/IO/outputs/1
  → 获取指定 I/O 输出状态（编号 1）

- PUT /ISAPI/System/IO/outputs/<ID>/trigger <IOPortData><outputState>high</outputState></IOPortData>
  → 触发指定 I/O 输出为高电平

- PUT /ISAPI/System/IO/outputs/<ID>/trigger <IOPortData><outputState>low</outputState></IOPortData>
  → 触发指定 I/O 输出为低电平
```

> 以上只是常用命令的一部分，更多命令可参考官方 SDK 文档在线获取。


