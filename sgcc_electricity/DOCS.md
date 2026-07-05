# SGCC Electricity Add-on 配置说明

镜像来源：[wuwweizn/sgcc_electricity_new](https://github.com/wuwweizn/sgcc_electricity_new)

## 必填参数

| 参数 | 说明 |
|------|------|
| `PHONE_NUMBER` | 国网登录手机号 |
| `PASSWORD` | 国网登录密码 |
| `HASS_URL` | Home Assistant 地址，如 `http://homeassistant.local:8123/` |
| `HASS_TOKEN` | HA 长期访问令牌（个人资料 → 安全 → 长期访问令牌） |
| `LLM_API_KEY` | 大模型 API Key，用于自动解算腾讯验证码 |
| `LLM_MODEL` | 模型名称，火山引擎填接入点 ID（如 `ep-2025xxxxxx-xxxxx`） |

## 可选参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `LLM_BASE_URL` | 空（使用火山引擎默认） | 其他兼容 OpenAI 接口的大模型地址 |
| `IGNORE_USER_ID` | `xxxx,xxxx` | 需要忽略的户号，多个用英文逗号分隔 |
| `JOB_START_TIME` | `07:00` | 每日执行时间（24小时制），每12小时执行一次 |
| `RETRY_WAIT_TIME_OFFSET_UNIT` | `15` | 页面操作等待时间（秒），范围 2~30 |
| `DATA_RETENTION_DAYS` | `7` | 保留历史数据天数（7 或 30） |
| `BALANCE` | `5.0` | 余额低于此值时发送通知（元） |
| `PUSHPLUS_TOKEN` | 空 | PushPlus token，用于余额不足通知 |

## 大模型配置（火山引擎豆包）

1. 注册 [火山引擎](https://www.volcengine.com/) 并完成实名认证
2. 进入 [火山方舟控制台](https://console.volcengine.com/ark) → 在线推理 → 创建推理接入点，选择 `Doubao-Seed-2.0-pro-260215`
3. API Key 管理 → 创建并复制 API Key
4. 将接入点 ID 填入 `LLM_MODEL`，API Key 填入 `LLM_API_KEY`

## 二维码登录

当遭遇腾讯风控拦截时，加载项自动切换为二维码登录：

1. HA 界面左下角铃铛出现红点通知（标题：⚡ 国网需要扫码登录）
2. 点开通知，用**国家电网 App** 扫描二维码
3. 加载项等待 180 秒，请在此时间内完成扫码

## 启动

保存配置后，点击「启动」，在「日志」标签页查看运行状态。正常运行时日志类似：

```
Google Chrome for Testing 120.0.6099.109
浏览器驱动已初始化。
通过点击验证码登录成功。
用户 [xxxxxxx] 数据获取完成: 余额=xxx元
```
