FRP Client Plus

frp增强版 实现对本地Ha以及同局域网的服务和设备穿透进行远程访问。

## 配置说明

- 按照实际情况填写相关"配置"

- 修改Home Assistant `config/configuration.yaml` 添加：

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 127.0.0.1
```
修改之后，重启HA

- 配置参数解释：
1、服务器连接配置
```yaml
serverAddr: frp.freefrp.net
serverPort: 7000
authToken: freefrp.net

2、需穿透的服务配置
proxies:(注：不要把proxies:配置进去，仅以下内容)
  - name: "nas_http"
    type: "http"
    localIP: "192.168.0.8"
    localPort: 5000
    customDomains: "nas.wuweizhineng.com"
  - name: "nas_https"
    type: "https"
    localIP: "192.168.0.8"
    localPort: 5001
    customDomains: "nas.wwzn.com"
  - name: "ssh"
    type: "tcp"
    localIP: "192.168.0.21"
    localPort: 22
    remotePort: 2222
  - name: "win10"
    type: "tcp"
    localIP: "192.168.0.10"
    localPort: 3389
    remotePort: 3333
```
#### 请不要在配置文件中注释中文，参考以下文档仔细修改每条参数。

服务配置分为需要 **Web** 访问的 **HTTP / HTTPS** 协议和 **TCP / UDP** 协议。

---

### 服务器连接配置

服务提供商提供的 frp 服务器信息配置
```yaml
serverAddr: "frp.freefrp.net" #frp 服务器 IP 地址或者域名地址
serverPort: 7000 #frp 服务端口号
authToken: "freefrp.net" #服务端配置的 token 密码
```

---

### HTTP / HTTPS 协议 Web 穿透服务

同一个域名只能穿透一个 HTTP / HTTPS 服务，如需穿透多个 Web，请分别为每个 Web 服务分配各自的域名，并正确的将 CNAME 或 A 记录指向 frp 服务器的域名或 IP。

**例如**：示例中 **nas.wuweizhineng.com** 已经分别配置到了群晖 NAS 的 HTTP 和 HTTPS 端口。
如果本地还有其他例如博客的 Web 服务器需要穿透，请再分配例如 www.wuweizhineng.com 或 blog.wuweizhineng.com 的二级域名来使用。


```yaml
- name: "nas_http" #（可选）服务名称： 此处为该条穿透服务的名称，必须修改，且不能与其他用户重复。
  type: "http" #（必选）协议类型： 确保本条穿透服务使用此协议能够在内网正常使用或访问。例如，尝试在本地访问 http://内网IP:内网端口 确保能够正常浏览。
  localIP: "192.168.0.8" #（必选）内网 IP：本地服务所在设备的内网 IP 地址。由于 frp 客户端有可能安装在 docker 容器中，所以请不要使用 127.0.0.1 来表示本机 IP。
  localPort: 5000 #（必选）本地端口：本地服务的端口号。例如群晖 NAS 的 HTTP 管理端口号为 5000。
  customDomains: "nas.quweizhineng.com" #（必选）自定义域名：为本条穿透服务提供的域名
注意：请确保在域名服务商后台将该域名的 CNAME 指向了本 frp 服务器地址，也就是上文的 serverAddr 地址，如果 serverAddr 为 IP，则指向 A 记录到服务器 IP。配置成功后可以使用 http://nas.wuweizhineng.com 访问你的群晖 NAS。
```
**重点提示**：当 **type = "http"** 或者 **"https"** 协议时, **custom_domains** 必须存在。**如果没有此参数会导致 frp 客户端无法启动。**

---

```yaml
- name: "nas_https" #（可选）服务名称： 此处为该条穿透服务的名称，必须修改，且不能与其他用户重复。
  type: "https" #（必选）协议类型： 确保本条穿透服务使用此协议能够在内网正常使用或访问。例如，尝试在本地访问 https://内网IP:内网端口 确保能够正常浏览。
  localIP: "192.168.0.8" #（必选）内网 IP：本地服务所在设备的内网 IP 地址。由于 frp 客户端有可能安装在 docker 容器中，所以请不要使用 127.0.0.1 来表示本机 IP。
  localPort: 5001 #（必选）本地端口：本地服务的端口号。例如群晖 NAS 的 HTTPS 管理端口号为 5001。
  customDomains: "nas.wwzn.com" #（必选）自定义域名：为本条穿透服务提供的域名
注意：请确保在域名服务商后台将该域名的 CNAME 指向了本 frp 服务器地址，也就是上文的 serverAddr 地址，如果 serverAddr 为 IP，则指向 A 记录到服务器 IP。配置成功后可以使用 http://nas.wwzn.com 访问你的群晖 NAS。
```
**重点提示**：当 **type = "http"** 或者 **"https"** 协议时, **custom_domains** 必须存在。**如果没有此参数会导致 frp 客户端无法启动。**

---

### TCP/UDP

```yaml
- name: ssh #（可选）服务名称： 此处为该条穿透服务的名称，必须修改，且不能与其他用户重复。
  type: tcp #（必选）协议类型： 确保本条穿透服务使用此协议能够在内网正常使用或访问。例如，尝试在本地终端执行 ssh root@192.168.0.21 确保能够正常登录。
  localIP: 192.168.0.21 #（必选）内网 IP：本地服务所在设备的内网 IP 地址。由于 frp 客户端有可能安装在 docker 容器中，所以请不要使用 127.0.0.1 来表示本机 IP。
  localPort: 22 #（必选）本地端口：本地服务的端口号。例如，本地 linux 服务器的默认 SSH 登录端口为 22。
  remotePort: 2222 #（必选）远程端口：远程服务的端口号。自定义填写一个远程服务端口号，例如 2222，成功连接后，可以使用 ssh -p 2222 root@frp.freefrp.net 来远程登录你的内网 Linux 服务器。
```

**远程端口号（remotePort）必须根据服务提供商提供的服务端口范围进行自选填写，确保不要与其他用户重复，如果访问的内容不是自己的服务，则表示该端口号已被其他用户使用。此条记录重复或者超出端口号范围会导致无法连接或者 frp 客户端无法启动。**

**重点提示**：当 **type = "tcp"** 时，无需配置上文的两条域名记录，可以直接使用 frp 服务器的地址作为域名，也可以将自己的域名 CNAME 或 A 记录 指向 frp 服务器的域名或 IP。

---

```yaml
- name: win10 #（可选）服务名称： 此处为该条穿透服务的名称，必须修改，且不能与其他用户重复。
  type: tcp #（必选）协议类型：确保本条穿透服务使用此协议能够在内网正常使用或访问。例如，尝试在本地使用 Microsoft Remote Desktop 来远程访问该电脑，确保能够正常登录。
  localIP: 192.168.0.10 #（必选）内网 IP：本地服务所在设备的内网 IP 地址。由于 frp 客户端有可能安装在 docker 容器中，所以请不要使用 127.0.0.1 来表示本机 IP。
  localPort: 3389 #（必选）本地端口：本地服务的端口号。例如，本地 Windows RDP 的默认端口为 3389。
  remotePort: 3333 #（必选）远程端口：远程服务的端口号。自定义填写一个远程服务端口号，例如 3333，成功连接后，可以使用 Microsoft Remote Desktop 将地址填写为 frp.freefrp.net:3333 来远程登录你的内网 Windows。
```
**远程端口号（remotePort）必须根据服务提供商提供的服务端口范围进行自选填写，确保不要与其他用户重复，如果访问的内容不是自己的服务，则表示该端口号已被其他用户使用。此条记录重复或者超出端口号范围会导致无法连接或者 frp 客户端无法启动。**

**重点提示**：当 **type = tcp** 时，无需配置上文的两条域名记录，可以直接使用 frp 服务器的地址作为域名，也可以将自己的域名 CNAME 或 A 记录 指向 frp 服务器的域名或 IP。

- 源码：https://github.com/huxiaoxu2019/hass-addon-frp-client
- 文档：https://gofrp.org/zh-cn/
- 依赖：https://github.com/fatedier/frp

