# 源代码链接

* [前端](https://github.com/CoolKit-Technologies/ha-addon-frontEnd)
* [后端](https://github.com/CoolKit-Technologies/ha-addon-backEnd)

---

# Home-Assistant 插件

## 插件说明：

* 参考 [Wiki](https://bit.ly/eWeLinkaddon)

## Docker 部署：

* **使用主机网络以发现并控制 DIY 和局域网设备。**
* **目前不支持端口转发，请确保端口 3000 未被占用。**

1. 克隆仓库：

```bash
git clone https://github.com/CoolKit-Technologies/ha-addon.git
```

2. 进入插件目录：

```bash
cd ha-addon/eWeLink_Smart_Home/
```

3. 构建 Docker 镜像：

```bash
docker build . -t ewelink_smart_home
```

4. 运行 Docker 容器，替换 `yourHomeAssistantUrl` 为你当前的 Home Assistant URL：

```bash
docker run -d \
    --restart=unless-stopped \
    --network host \
    -e HA_URL=yourHomeAssistantUrl \
    -e SUPERVISOR_TOKEN=yourHomeAssitantLongLivedAccessToken \
    -v ./volume:/data \
    --name ewelink_smart_home \
    ewelink_smart_home
```

* 示例：

```bash
docker run -d \
    --restart=unless-stopped \
    --network host \
    -e HA_URL=http://192.168.1.100:8123 \
    -e SUPERVISOR_TOKEN=eyJ~iJ9.eyJ~jF9.CkQ~Lho \
    -v ./volume:/data \
    --name ewelink_smart_home \
    ewelink_smart_home
```

5. 访问端口 `3000`。
