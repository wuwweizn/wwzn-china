＃家庭助理社区附件：蓝牙-MQTT-GATEWAY
![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]
![Project Maintenance][maintenance-shield]

＃项目已由原始创建者弃用，因此此附件不会收到新功能
Please have a look [here](https://github.com/zewelor/bt-mqtt-gateway), it is recommended to use Bluetooth Proxy.

蓝牙-MQTT-GATEWAY用于 Homeassistant OS

##关于
一个简单的Python脚本，该脚本为MQTT Gateway提供了蓝牙，可以通过自定义工人易于扩展。
See [Wiki](https://github.com/zewelor/bt-mqtt-gateway/wiki) for more information (supported devices, features and much more).

这可以使用，以提高蓝牙恒温器的真实性。See <https://github.com/home-assistant/core/issues/28601> for more informations.

##安装
此附加组件的安装非常简单，并且与安装任何其他自定义家庭助手附加组件相比并没有什么不同。
只需将我的回购添加到Hassio addons存储库中：<https://github.com/faserf/hassio-addons>

将您的配置文件放在 /share/bt-mqtt-gateway.yaml上，
请确保已经安装了MQTT插件。

＃＃ 配置

**注意**：_remember在更改配置时重新启动附加组件。他们尚未实施，但计划！！！

示例附加配置：

```yaml
config_path: /share/bt-mqtt-gateway.yaml
debug: true
```

**注意**：_这个只是一个例子，不要复制并粘贴它！创建自己的！_

###选项：
`config_path`需要此选项。根据您的配置文件在荷马抗安装上的位置进行更改。

###选项：
`debug`将此选项设置为“ true”将在调试模式下启动插件。默认值：false
- >启用调试模式，请在 /share/bt-mqtt-gateway-debug.txt上创建一个空文件
##支持
有问题吗？您可以[在此处打开一个问题] [问题] github。
请记住，该软件仅在Raspberry Pi 4上运行的ARMV7上测试。

## Authors & contributors

The original program is from @zewelor. For more informatios please visit this page: <https://github.com/zewelor/bt-mqtt-gateway>
The hassio addon is brought to you by [FaserF].

## License

MIT License

Copyright (c) 2022 FaserF & zewelor

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[FaserF]: https://github.com/FaserF/
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[issue]: https://github.com/FaserF/hassio-addons/issues
[maintenance-shield]: https://img.shields.io/maintenance/no/2024.svg
