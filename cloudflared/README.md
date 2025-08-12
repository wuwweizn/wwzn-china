＃家庭助理插件：Cloudflared

[![GitHub Release][releases-shield]][releases]
![Project Stage][project-stage-shield]
![Project Maintenance][maintenance-shield]
![Reported Installations][installations-shield-stable]

远程连接到您的家庭助理实例，而无需使用Cloudflared打开任何端口。

＃＃ 关于

Cloudflared通过安全的隧道将您的家庭助手实例连接到Cloudflare的域或子域。
这样做，您可以将您的家庭助理公开互联网，而无需在路由器中打开端口。
此外，您可以利用Cloudflare团队，即零信任平台，以进一步保护您的家庭助理连接。

**要使用此附加组件，您必须拥有一个使用CloudFlare作为DNS条目的域名（EG示例）。
您可以在我们的[Wiki] [Wiki] **
中找到有关此信息的更多信息。

##免责声明

使用此附加组件时，请确保符合[CloudFlare自助订阅协议] [CloudFlare-SSSA]。

[cloudflare-sssa]: https://www.cloudflare.com/terms/
[domainarticle]: https://www.linkedin.com/pulse/what-do-domain-name-how-get-one-free-tobias-brenner?trk=public_post-content_share-article
[maintenance-shield]: https://img.shields.io/maintenance/yes/2025.svg
[project-stage-shield]: https://img.shields.io/badge/project%20stage-production%20ready-brightgreen.svg
[releases-shield]: https://img.shields.io/github/v/release/brenner-tobias/addon-cloudflared?include_prereleases
[releases]: https://github.com/brenner-tobias/addon-cloudflared/releases
[wiki]: https://github.com/brenner-tobias/addon-cloudflared/wiki/How-tos
[installations-shield-edge]: https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fanalytics.home-assistant.io%2Faddons.json&query=%24%5B%22ffd6a162_cloudflared%22%5D.total&label=Reported%20Installations&link=https%3A%2F%2Fanalytics.home-assistant.io/add-ons
[installations-shield-stable]: https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fanalytics.home-assistant.io%2Faddons.json&query=%24%5B%229074a9fa_cloudflared%22%5D.total&label=Reported%20Installations&link=https%3A%2F%2Fanalytics.home-assistant.io/add-ons