＃家庭助理社区：KNXD
KNXD 是一个开源的守护进程（daemon），用于在 Linux 系统上管理 KNX 总线
（KNX 是一种智能建筑自动化总线协议）。
它负责通过各种硬件接口与 KNX 总线通信，实现对 KNX 设备的读取和控制。
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports i386 Architecture][i386-shield]

＃＃ 关于

`knxd`是一种Linux工具，可以用作路由器/网关，可以与KNX总线上的设备通信。
此附加组件提供了“ KNXD”守护程序，
您可以使用TPUART或USB总线适配器从家庭安装中创建KNX/IP网关。
因此，基本上，它可以将UART/USB接口转换为KNX IP-Interfaces，
然后您可以将其用于霍姆斯耐药或通过以太网通过ETS对KNX设备进行编程。有关更多详细信息，请参见https://github.com/knxd/knxd。

##安装和配置

See [documentation](DOCS.md)

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
