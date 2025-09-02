# Home Assistant 插件：Hikvision 门铃

---

## 配置

**注意**：*修改配置后请记得重启插件*。

**注意**：*首次连接门铃时，可能会出现门铃卡住的情况，因为它在下载完整的历史事件。这期间会出现大量错误事件，请耐心等待，有时可能需要几小时，甚至需要重启。*

在 Home Assistant 界面插件的 **Configuration** 选项卡中，可配置以下选项：

---

### 门铃配置（Doorbells）

配置与门铃的连接，如果未定义值，则使用默认设置。

每个门铃需重复以下配置：

| 选项             | 默认值   | 描述                                  |
| -------------- | ----- | ----------------------------------- |
| name           |       | 门铃自定义名称（在 HA UI 和传感器名称中显示）          |
| ip             |       | 门铃 IP 地址                            |
| port           | 8000  | （可选）门铃端口                            |
| username       | admin | 访问门铃用户名                             |
| password       |       | 访问门铃密码                              |
| output\_relays | 2     | （可选）如果看不到正确数量的门开关，或有安全门控制模块连接，可调整此值 |
| scenes         | false | （可选）室内面板的额外场景按钮                     |

#### 示例配置

配置两个门铃 `Front door` 和 `Rear door`，以及一个 `Indoor` 室内面板：

```yaml
- name: "Front door"
  ip: 192.168.0.1
  username: admin
  password: password  

- name: "Rear door"
  ip: 192.168.0.2
  username: admin
  password: password

- name: "Indoor"
  ip: 192.168.0.3
  username: admin
  password: password

- name: "Indoor Extension"
  ip: 192.168.0.4
  username: admin
  password: password
```

---

### 系统配置（System）

可配置系统相关设置：

| 名称              | 默认值     | 描述                                                    |
| --------------- | ------- | ----------------------------------------------------- |
| log\_level      | WARNING | 插件日志详细等级，可选：*ERROR* *WARNING* *INFO* \_DEBUG          |
| sdk\_log\_level | NONE    | Hikvision SDK 日志详细等级，可选：*NONE* *ERROR* *INFO* \_DEBUG |

#### 示例配置

```yaml
log_level: WARNING
sdk_log_level: NONE
```

---

## 安装与设置

### 需求

* 需要一个正在运行的 **MQTT Broker**。
* 可以使用官方支持的 **Mosquitto Broker**，在 Home Assistant 官方插件中可安装。
  点击此按钮快速安装：
  [![安装 Mosquitto](https://my.home-assistant.io/badges/supervisor_addon.svg)](https://my.home-assistant.io/redirect/supervisor_addon/?addon=core_mosquitto)
* 安装并启动 Mosquitto 后，可在 `设置 -> 设备与服务 -> MQTT` 中点击 **Configure** 自动连接 Home Assistant。

（可选）如果使用外部 MQTT Broker，可在插件配置中设置：

```yaml
host: 192.168.0.17
port: 1883
ssl: false
username: user
password: pass
```

---

### 快速开始

配置好 MQTT 后，启动 **Hikvision Doorbell** 插件。
每个配置的门铃会作为设备出现在 `设置 -> 设备与服务 -> 设备` 中。

---

### 传感器、开关、输入文本和按钮

每个门铃可用实体：

* **传感器（Sensors）**

  * `Call state`（呼叫状态）：*idle*、*ringing*、*dismissed*

* **开关（Switches）**

  * `Door relays`（门继电器开关）：每个继电器控制门的开关

* **按钮（Buttons）**

  * `Answer call`（接听）：需连接 Hikconnect 才能使用
  * `Hangup call`（挂断）
  * `Reject call`（拒绝）
  * `Reboot`（重启）
  * …

* **设备触发器（Device triggers，依设备型号而定）**

  * `Motion detected`（检测到移动）
  * `Tamper alarm`（防拆警报）
  * `Door not closed`（门未关闭）
  * …

> 设备触发器用于标记门铃产生的事件（具体事件取决于型号），这些触发器没有状态，不会在 HA 实体列表中显示，但可在每个设备信息页面查看。

**注意**：触发器会在设备至少触发一次事件后被发现。

**注意**：如果没有 “门未关闭” 触发器，可参考以下方案：
[社区讨论链接1](https://community.home-assistant.io/t/hikvision-doorbell-videointercom-integration/532796/537)
[社区讨论链接2](https://community.home-assistant.io/t/hikvision-doorbell-videointercom-integration/532796/2297)

可在自动化中使用 **设备触发器**，类型为 `Device`。
详细自动化参考：
[自动化入门](https://www.home-assistant.io/getting-started/automation/)
[自动化文档](https://www.home-assistant.io/docs/automation/)

* **输入文本（Input Text）**

  * `Isapi request`：用于向室内/室外设备发送 ISAPI 命令。室内设备的 80 端口可能关闭，但可通过此插件使用 SDK 发送命令。
  * **注意**：错误使用可能导致插件/容器崩溃。
  * 必须使用 GET/PUT，ISAPI 命令必填，JSON/XML 可选。

示例：

```yaml
# 获取呼叫状态
action: text.set_value
target:
  entity_id: text.ds_kd8003_isapi_request
data:
  value: GET /ISAPI/VideoIntercom/callStatus?format=json

# 开门
action: text.set_value
target:
  entity_id: text.ds_kd8003_isapi_request
data:
  value: PUT /ISAPI/AccessControl/RemoteControl/door/1 <RemoteControlDoor><cmd>open</cmd></RemoteControlDoor>
```

---

## 向门铃发送命令

有两种方式与门铃交互：

1. 使用自动创建的 **MQTT 实体**（开关、按钮）
2. 使用插件的 **STDIN 服务（高级）**

---

### MQTT 实体

插件会自动创建可在 HA UI 或自动化中操作的 **开关** 和 **按钮**。

---

### STDIN 服务（高级）

可通过向插件的 **标准输入（STDIN）** 发送文本命令与设备交互，使用内置服务 `hassio.addon_stdin`。

输入格式：

```
<command> <doorbell_name> <optional_parameter>
```

* `<command>` 可选命令：

| 命令                | 描述                                       |
| ----------------- | ---------------------------------------- |
| unlock            | 解锁门（optional\_parameter = 1 或 2，指定输出继电器） |
| reboot            | 重启门铃                                     |
| reject            | 拒绝来电，停止室内设备响铃                            |
| request           | 未知                                       |
| cancel            | 未知                                       |
| answer            | 接听来电，可结合 hangUp 使用进行双向音频                 |
| hangUp            | 挂断来电，可结合 answer 使用                       |
| deviceOnCall      | 未知                                       |
| atHome            | 发送 “在家” 场景到室内面板                          |
| goOut             | 发送 “外出” 场景到室内面板                          |
| goToBed           | 发送 “就寝” 场景到室内面板                          |
| custom            | 发送自定义场景                                  |
| setupAlarm        | 开启室内面板警报                                 |
| closeAlarm        | 关闭警报                                     |
| muteAudioOutput   | 静音门铃/室内音频输出                              |
| unmuteAudioOutput | 取消静音门铃/室内音频输出                            |

* `<doorbell_name>`：配置中门铃的自定义名称，全部小写，空格用下划线 `_` 替换
  例：门铃名 `Front door`，需写作 `front_door`

* `<optional_parameter>`：命令的额外参数（视命令而定）

#### 示例

**解锁门**（门铃 `Front door` 第 1 继电器）：

```yaml
service: hassio.addon_stdin
data:
  addon: aff2db71_hikvision_doorbell
  input: unlock front_door 1
```

**重启设备**（门铃 `Rear door`）：

```yaml
service: hassio.addon_stdin
data:
  addon: aff2db71_hikvision_doorbell
  input: reboot rear_door
```

**拒绝来电**（配合传感器使用，当有人按门铃时，如果门手动打开，可自动拒绝）：

```yaml
service: hassio.addon_stdin
data:
  addon: aff2db71_hikvision_doorbell
  input: reject indoor_unit
```

> 该命令在室内机上执行（例如 DS-KD8003 室外单元 + 室内机 `Indoor unit`），可停止 Hik-Connect 设备响铃。

---

## 支持

如发现 BUG 或需技术支持，请在 GitHub [提交 Issue](https://github.com/pergolafabio/Hikvision-Addons/issues/new)。
尽量提供日志以便排查问题。

---

### 故障排查

查看 Home Assistant 插件的 **Log** 选项卡。

可通过修改配置增加日志详细度：

```yaml
system:
  log_level: DEBUG
  sdk_log_level: DEBUG
```

**注意**：首次连接门铃时，可能会卡住，因为它在下载完整事件历史，有时需要重启插件。

