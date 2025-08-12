##＆＃9888;开放问题：[[FileBrowser]在新安装上崩溃（开放2025-08-02）]（https://github.com/alexbelgium/alexbelgium/hassio-addons/issues/1993），作者：[@livart01]

[![Donate][donation-badge]](https://www.buymeacoffee.com/alexbelgium)
[![Donate][paypal-badge]](https://www.paypal.com/donate/?hosted_button_id=DZFULJZTP3UQA)

![Version](https://img.shields.io/badge/dynamic/json?label=Version&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2Falexbelgium%2Fhassio-addons%2Fmaster%2Ffilebrowser%2Fconfig.json)
![Ingress](https://img.shields.io/badge/dynamic/json?label=Ingress&query=%24.ingress&url=https%3A%2F%2Fraw.githubusercontent.com%2Falexbelgium%2Fhassio-addons%2Fmaster%2Ffilebrowser%2Fconfig.json)
![Arch](https://img.shields.io/badge/dynamic/json?color=success&label=Arch&query=%24.arch&url=https%3A%2F%2Fraw.githubusercontent.com%2Falexbelgium%2Fhassio-addons%2Fmaster%2Ffilebrowser%2Fconfig.json)

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/9c6cf10bdbba45ecb202d7f579b5be0e)](https://www.codacy.com/gh/alexbelgium/hassio-addons/dashboard?utm_source=github.com&utm_medium=referral&utm_content=alexbelgium/hassio-addons&utm_campaign=Badge_Grade)
[![GitHub Super-Linter](https://img.shields.io/github/actions/workflow/status/alexbelgium/hassio-addons/weekly-supelinter.yaml?label=Lint%20code%20base)](https://github.com/alexbelgium/hassio-addons/actions/workflows/weekly-supelinter.yaml)
[![Builder](https://img.shields.io/github/actions/workflow/status/alexbelgium/hassio-addons/onpush_builder.yaml?label=Builder)](https://github.com/alexbelgium/hassio-addons/actions/workflows/onpush_builder.yaml)

[donation-badge]: https://img.shields.io/badge/Buy%20me%20a%20coffee%20(no%20paypal)-%23d32f2f?logo=buy-me-a-coffee&style=flat&logoColor=white
[paypal-badge]: https://img.shields.io/badge/Buy%20me%20a%20coffee%20with%20Paypal-0070BA?logo=paypal&style=flat&logoColor=white

_Thanks to everyone having starred my repo! To star it click on the image below, then it will be on top right. Thanks!_

[![Stargazers repo roster for @alexbelgium/hassio-addons](https://raw.githubusercontent.com/alexbelgium/hassio-addons/master/.github/stars2.svg)](https://github.com/alexbelgium/hassio-addons/stargazers)

![downloads evolution](https://raw.githubusercontent.com/alexbelgium/hassio-addons/master/filebrowser/stats.png)

## 关于

基于Web的文件管理界面，可提供安全的方法，以浏览，上传，下载，编辑和管理您的家庭助理系统上的文件。 FileBrowser提供了一个干净的现代界面，用于通过Web浏览器处理文件，并支持多种文件格式，预览功能和全面的文件操作。

这个插件基于 [docker image](https://hub.docker.com/r/filebrowser/filebrowser) 来自官方FileBrowser项目。

##安装

与安装任何其他家庭助手附加组件相比，此附加组件的安装非常简单，并且没有什么不同。

1.[将我的家庭助理附加存储库] [存储库]添加到您的家庭助理实例中。
2.安装此附加组件。 
3.单击“保存”按钮以存储您的配置。 
4.启动附加组件。
5.检查附加组件的日志，以查看一切是否进展顺利。
6.通过侧边栏或访问Web UI `<your-ip>:8071`.

##配置

可以在 `<your-ip>:8071` 或使用入学时通过家庭助理侧边栏。

**默认凭据：**
- Username: `admin`
- Password: `admin`

**重要：**首先登录安全性后立即更改默认凭据。

＃＃＃ 选项

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `ssl` | bool | `false` | Enable HTTPS for web interface |
| `certfile` | str | `fullchain.pem` | SSL certificate file (in `/ssl/`) |
| `keyfile` | str | `privkey.pem` | SSL private key file (in `/ssl/`) |
| `NoAuth` | bool | `true` | Disable authentication (resets database when changed) |
| `disable_thumbnails` | bool | `true` | Disable thumbnail generation for improved performance |
| `base_folder` | str | *(optional)* | Root folder for file browser (defaults to all mapped folders) |
| `localdisks` | str | *(optional)* | Local drives to mount (e.g., `sda1,sdb1,MYNAS`) |
| `networkdisks` | str | *(optional)* | SMB shares to mount (e.g., `//SERVER/SHARE`) |
| `cifsusername` | str | *(optional)* | SMB username for network shares |
| `cifspassword` | str | *(optional)* | SMB password for network shares |
| `cifsdomain` | str | *(optional)* | SMB domain for network shares |

###示例配置

```yaml
ssl: true
certfile: "fullchain.pem"
keyfile: "privkey.pem"
NoAuth: false
disable_thumbnails: false
base_folder: "/share"
localdisks: "sda1,sdb1"
networkdisks: "//192.168.1.100/files,//nas.local/documents"
cifsusername: "fileuser"
cifspassword: "password123"
cifsdomain: "workgroup"
```

＃＃ 设置

1. 启动加载项并等待它初始化.
1. 通过家庭助理侧边栏或位置访问Web界面 `<your-ip>:8071`.
1. 使用默认凭据登录:
   - Username: `admin`
   - Password: `admin`
1. **重要：**立即通过单击更改默认密码 "设置" > "用户管理".
1. 通过Web界面配置您的首选设置。
1. 如果已禁用身份验证（`noauth：true`），则将绕过登录屏幕。

###安装驱动器

此插件支持安装本地驱动器和远程SMB共享：

- **Local drives**: See [Mounting Local Drives in Addons](https://github.com/alexbelgium/hassio-addons/wiki/Mounting-Local-Drives-in-Addons)
- **Remote shares**: See [Mounting Remote Shares in Addons](https://github.com/alexbelgium/hassio-addons/wiki/Mounting-remote-shares-in-Addons)

###自定义脚本和环境变量

此插件通过`addon_config`映射支持自定义脚本和环境变量：

- **Custom scripts**: See [Running Custom Scripts in Addons](https://github.com/alexbelgium/hassio-addons/wiki/Running-custom-scripts-in-Addons)
- **Environment variables**: See [Add Environment Variables to your Addon](https://github.com/alexbelgium/hassio-addons/wiki/Add-Environment-variables-to-your-Addon)

＃＃ 支持

Create an issue on GitHub, or ask on the [Home Assistant Community thread](https://community.home-assistant.io/t/home-assistant-addon-filebrowser/282108/3).

[repository]: https://github.com/alexbelgium/hassio-addons
[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
