＃家庭助理社区附加组件：高级SSH和Web终端

[![Release][release-shield]][release] ![Project Stage][project-stage-shield] ![Project Maintenance][maintenance-shield]

[![Discord][discord-shield]][discord] [![Community Forum][forum-shield]][forum]

[![Sponsor Frenck via GitHub Sponsors][github-sponsors-shield]][github-sponsors]

[![Support Frenck on Patreon][patreon-shield]][patreon]

此附加组件使您可以使用SSH或使用Web终端登录到家庭助理实例。

##关于
此附加组件，您可以使用SSH或Web终端登录到Home Assistant实例，
使您可以访问您的文件夹，还包含一个命令行工具，以执行诸如RESTART，更新和检查您的实例之类的操作。

这是提供的[SSH附加组件由家庭助理] [HASS-SSH]的增强版本，
并且专注于安全性，可用性，灵活性，并且还使用Web界面提供了访问。

![Web Terminal in the Home Assistant Frontend][screenshot]


##警告
高级SSH＆Web终端附加组件非常强大，可让您几乎可以访问系统的所有工具以及系统的所有硬件。
当此附加组件是在谨慎和安全上创建和维护的，但要在错误或缺乏经验的手中，可能会损害您的系统。

##当然
此附加组件也提供了基于[OpenSSH] [OpenSSH]和基于Web的终端（可以包含在您的家庭助理前端）的SSH服务器。
此外，它的开箱即用：
- 从家庭助理前端访问您的命令行！
-  SSH的安全默认配置：
 - 仅允许配置的用户登录，即使创建了更多用户。
 - 仅使用已知的安全密码和算法。
 - 限制登录试图更好地阻止蛮力攻击。
- 带有SSH兼容模式选项，可让较老的客户连接。
- 支持MOSH允许漫游并支持间歇性连接。
-SFTP支持默认情况下是禁用的，但用户可配置。
- 如果通过通用Linux安装程序安装家庭助手，则兼容。
- 用户名是可配置的，因此`root'不再是强制性的。
- 在附加重新启动之间进行自定义SSH客户端设置和键
- 日志级别允许您更容易分类问题。
- 硬件访问您的音频，UART/串行设备和GPIO引脚。
- 拥有更多特权，使您可以调试和测试更多情况。
- 可以访问主机系统的DBU。
- 可以选择访问主机系统上运行的Docker实例。
- 在主机级网络上运行，允许您打开端口或运行小守护程序。
- 在开始时安装了自定义的高山软件包。这使您可以安装您最喜欢的工具，每次登录时都可以使用。
- 在附加启动上执行自定义命令，以便您可以根据自己的喜好自定义外壳。
-  [zsh] [zsh]作为默认外壳。对于初学者而言，更易于使用，对于经验丰富的用户而言，更高级。
它甚至还带有[“哦，我的zsh”] [ohmyzsh]，还启用了一些插件。
- 包含一组明智的工具：Curl，Wget，rsync，git，nmap，Nmap，Mosquitto客户端，
Mariadb/Mysql客户端，Awake（“ Wake on LAN”），Nano，vim，tmux和一种常用的网络工具。

[discord-shield]: https://img.shields.io/discord/478094546522079232.svg
[discord]: https://discord.me/hassioaddons
[forum-shield]: https://img.shields.io/badge/community-forum-brightgreen.svg
[forum]: https://community.home-assistant.io/t/community-hass-io-add-on-ssh-web-terminal/33820?u=frenck
[github-sponsors-shield]: https://frenck.dev/wp-content/uploads/2019/12/github_sponsor.png
[github-sponsors]: https://github.com/sponsors/frenck
[hass-ssh]: https://home-assistant.io/addons/ssh/
[maintenance-shield]: https://img.shields.io/maintenance/yes/2025.svg
[ohmyzsh]: http://ohmyz.sh/
[openssh]: https://www.openssh.com/
[patreon-shield]: https://frenck.dev/wp-content/uploads/2019/12/patreon.png
[patreon]: https://www.patreon.com/frenck
[project-stage-shield]: https://img.shields.io/badge/project%20stage-production%20ready-brightgreen.svg
[release-shield]: https://img.shields.io/badge/version-v21.0.2-blue.svg
[release]: https://github.com/hassio-addons/addon-ssh/tree/v21.0.2
[screenshot]: https://github.com/hassio-addons/addon-ssh/raw/main/images/screenshot.png
[zsh]: https://en.wikipedia.org/wiki/Z_shell