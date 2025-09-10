# TradingAgents-CN Home Assistant Add-on


- Web UI: `http://<HA-IP>:8501`
- 需要在加载项配置中填入对应的 API Key（OpenAI / DeepSeek / Gemini / Qwen / Tavily 等）。


## 选项（Options）
- `openai_api_key`
- `deepseek_api_key`
- `gemini_api_key`
- `qwen_api_key`
- `tavily_api_key`
- `other_env`: 额外环境变量，`FOO=bar` 形式的字符串数组。


> 以上选项会在启动时写入容器内 `/app/.env`。


## 镜像命名
- GHCR: `ghcr.io/wuwweizn/tradingagents-cn-{arch}:{version}`
- Docker Hub: `<你的DOCKER_USERNAME>/tradingagents-cn-{arch}:{version}`


## 支持架构
- `amd64`, `aarch64`, `armv7`




# TradingAgents-CN Home Assistant Add-on

基于多智能体LLM的中文金融交易框架 Home Assistant 加载项。

## 关于

TradingAgents-CN 是一个革命性的多智能体金融交易决策框架，专为中文用户提供完整的文档体系和本地化支持。

### 特性

- 🎯 多智能体协作交易决策
- 🇨🇳 完整中文支持和A股数据
- 🧠 支持多种LLM模型（阿里百炼、Google AI、OpenAI等）
- 🌐 现代化Web界面
- 📊 实时数据分析和可视化
- 🗄️ 数据库集成支持

## 安装

1. 在 Home Assistant 中添加此存储库
2. 安装 "TradingAgents-CN" 加载项
3. 配置必需的API密钥
4. 启动加载项

## 配置

### 必需配置

- `dashscope_api_key`: 阿里百炼API密钥
- `finnhub_api_key`: FinnHub API密钥（用于股票数据）

### 可选配置

- `google_api_key`: Google AI API密钥
- `openai_api_key`: OpenAI API密钥
- `anthropic_api_key`: Anthropic API密钥
- `mongodb_enabled`: 启用MongoDB支持
- `redis_enabled`: 启用Redis缓存

## 使用

启动后访问 `http://homeassistant.local:8501` 使用Web界面。

## 支持

如需帮助，请访问：
- GitHub: https://github.com/wuwweizn/wwzn-china
- 原项目: https://github.com/hsliuping/TradingAgents-CN