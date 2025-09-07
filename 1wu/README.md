一、Home Assistant OS (HAOS)

这是最推荐的安装方式，官方维护的完整 Linux 发行版（基于 Buildroot）。

1. 安装方法

到 官方镜像下载页（国外官方版）
 下载适合设备的镜像（树莓派、x86小主机、虚拟机、NAS 等）。

到无为智能下载页（大陆版）
 下载适合设备的镜像（树莓派、x86小主机、虚拟机、NAS 等）。


刷入设备存储介质：

树莓派等 SBC → 使用 balenaEtcher
 刷写 SD 卡/SSD。

虚拟机、nas → 直接加载 VMDK/OVA/IMG。

启动设备，等待 Home Assistant 初始化，默认访问地址是 http://homeassistant.local:8123。

2. 升级方法

在 前端 → 设置 → 系统 → 更新 中一键升级。

或者使用 SSH 进入系统，运行：

ha os update   # 升级 HAOS 系统
ha supervisor update   # 升级 Supervisor
ha core update   # 升级 HA Core


也支持指定版本：

ha core update --version 2025.9.0

二、Docker 部署

适合已有 Linux 环境，灵活性高。

1. Home Assistant Core (最轻量)

只跑核心应用，不含 Supervisor 和插件系统。

安装：

docker run -d \
  --name homeassistant \
  --restart=unless-stopped \
  -v /PATH_TO_YOUR_CONFIG:/config \
  -e TZ=Asia/Shanghai \
  --network=host \
  ghcr.io/home-assistant/home-assistant:stable


/PATH_TO_YOUR_CONFIG 换成本地配置目录。

升级：

docker pull ghcr.io/home-assistant/home-assistant:stable
docker stop homeassistant
docker rm homeassistant
# 再重新 run 一次（挂载原有 /config 即可保留配置）

2. Home Assistant Container (推荐)

实际就是上面的 Core，但官方用 Container 名称，强调运行在 Docker 里。

支持同样的升级方式，拉取新镜像然后重启容器。

3. Home Assistant Supervised (高级)

在 Debian 上运行，保留 Supervisor、插件系统，接近 HAOS 功能，但对环境要求严格。

安装与升级都通过 ha 命令或 Supervisor 自动完成。

对比总结
部署方式	优点	缺点	升级方式
HAOS	官方完整系统，支持 Supervisor、插件、备份，最省心	系统被完全接管，不适合需要跑多服务的环境	前端点更新 / ha os update
Docker Core/Container	灵活，轻量，适合已有 Docker 体系	无 Supervisor，无附加插件	拉取新镜像 + 重建容器
Supervised	兼顾 Supervisor + 插件 + Debian	对系统依赖严格，出错率高	ha core update / Supervisor 自动更新