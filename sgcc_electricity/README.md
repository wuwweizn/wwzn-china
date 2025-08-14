# SGCC Electricity New – Home Assistant 加载项

将 [ARC-MX/sgcc_electricity_new](https://github.com/ARC-MX/sgcc_electricity_new) 封装为 HA 加载项，方便在 Home Assistant 中以后台服务方式运行。

> **注意**：此加载项为通用封装。由于上游项目实现细节可能不同，请根据实际文件结构，调整 `config.yaml` 中的 `command` 与 `args`（默认 `python3 main.py`）。

## 功能
- 以容器方式运行国网电量/余额查询脚本
- 通过 UI 配置登录信息 / 户号 / 轮询周期
- 可选暴露 HTTP 服务端口（若上游提供 Web API）

## 安装
1. 将本文件夹（`sgcc_electricity_new/`）放入你的 **Home Assistant Add-ons 仓库**。
2. 在仓库根目录准备 `repository.json` 并推送到 Git 仓库。
3. 在 Home Assistant 中：
   - 设置 → 加载项 → 加载项商店右上角菜单 → **存储库** → 添加你的仓库地址。
   - 在加载项列表中找到 **SGCC Electricity New** 并安装。

## 配置项（UI）
- `command`：启动命令，默认 `python3 main.py`。
- `args`：参数数组，例如 `["--debug"]`。
- `phone` / `password` / `token` / `cookie`：上游项目需要的认证信息（至少提供一种，视上游实现）。
- `account_id` / `city_code`：户号/区域等标识。
- `poll_interval`：轮询周期（秒）。
- `http_port`：若项目有 HTTP 服务，可设置对外端口。
- `extra_env`：额外环境变量键值对。

环境变量将以 `SGCC_` 前缀注入容器，可在上游代码中读取（例如 `os.getenv("SGCC_PHONE")`）。

## 日志与数据
- 日志：在加载项详情页 → 日志 中查看。
- 数据：可写入 `/data` 目录（容器内），在宿主上对应为 `addon_config` 挂载。

## 常见问题
- **程序入口文件不叫 `main.py`？** 请将 `command` 改为正确的启动入口，如 `python3 app.py` 或 `python3 -m sgcc` 等。
- **需要 Web 界面？** 若上游提供 FastAPI/Flask，保持 `ports: 8080`，并在 `run.sh` 中使用 uvicorn 启动即可。也可以开启 `ingress` 嵌入 HA。
- **需要定时运行一次并退出？** 可在 `run.sh` 中增加循环/定时器，或改用 `s6` 的 `cont-init.d`/`services.d`。

## 版本
- `1.0.0` 初始版本