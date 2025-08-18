Home Assistant 插件：AList
AList 是一款文件列表管理程序，支持多种存储方式，提供网页浏览功能，并支持 WebDAV。


#使用方法

1.启动插件

2.查看插件日志获取初始管理员密码

3.点击 OPEN WEB UI 或访问 http://[HOST]:5244 打开网页界面

4.使用用户名 admin 和生成的密码登录

5.在管理面板中配置存储后端

#配置

插件提供以下配置选项：

ssl: false
certfile: fullchain.pem
keyfile: privkey.pem

#选项：ssl（必填）

启用/禁用 AList 网页界面的 SSL（HTTPS）。
注意：如果使用 “Ingress” 功能，SSL 将由 Ingress 代理处理，此选项仅影响网页服务器。

#选项：certfile（如果启用 SSL 必填）

用于 SSL 的证书文件。

#选项：keyfile（如果启用 SSL 必填）

用于 SSL 的私钥文件。

#存储访问

插件会自动挂载以下目录：

/share - 访问 Home Assistant 的共享目录

/config - 访问 Home Assistant 配置目录

#默认端口

AList 默认运行在端口 5244。