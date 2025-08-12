＃家庭助理附加组件：基于文件编辑器
浏览器的配置文件编辑器，用于家庭助手。

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

![Configurator in the Home Assistant Frontend][screenshot]


##关于
文件编辑器，以前称为Configurator，是一个小型Web应用程序（您可以通过Web浏览器访问），
它提供了一个文件系统浏览器和文本编辑器来修改文件编辑器正在运行的计算机上的文件。

它由ACE编辑器提供动力，该编辑器支持语法突出显示各种代码/标记语言。
 YAML文件（家庭助手配置文件的默认语言）将在编辑时自动检查是否有语法错误。

##功能 
- 基于Web的编辑器，可以通过语法突出显示和YAML覆盖来修改您的文件。
- 上传和下载文件。
- 阶段，藏匿和提交GIT存储库中的更改，创建和切换分支之间，推动遥控器，查看diffs。
- 具有可用实体，触发器，事件，条件和服务的列表。
- 单击按钮直接重新启动家庭助理。重新加载组，自动化等也可以完成。需要一个API密码。
- 直接链接到家庭助理文档和图标。
- 在附加容器中执行shell命令。
- 编辑器设置保存在您的浏览器中。
- 还有更多…


[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[screenshot]: https://github.com/home-assistant/hassio-addons/raw/master/configurator/images/screenshot.png
