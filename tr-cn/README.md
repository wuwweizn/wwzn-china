# TradingAgents-CN Home Assistant 加载项使用说明

！！！！注意：此加载项对HA硬件要求 内存4GB+ RAM (推荐 8GB+)



### 2. 首次配置

#### 步骤1：获取API密钥

**阿里百炼API密钥 (推荐，国产大模型，中文优化)（必需）**
1. 访问 [阿里云百炼平台](https://dashscope.aliyun.com/)
2. 注册阿里云账号 -> 开通百炼服务 -> 获取API密钥
3. 格式: sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
4. 获取API Key

**Tushare API Token (A股必需推荐，专业的中国金融数据源)**
1. 获取地址: https://tushare.pro/register?reg=128886
2. 注册Tushare账号 -> 邮箱验证
3. 登录后进入个人中心 -> 获取Token
4.复制Token（格式：xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx）
# 注意：免费用户有调用频率限制，建议升级积分获得更高权限

**FinnHub API密钥（美股必需推荐 用于获取美股金融数据）**
1. 访问 [FinnHub](https://finnhub.io/)
2. 免费账户每分钟60次请求，足够日常使用
3. 获取API Key 格式: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



**其他API密钥（可选）**
- Google AI API：用于Gemini模型
- OpenAI API：用于GPT模型
- Anthropic API：用于Claude模型

#### 步骤2：配置Home Assistant加载项
1. 在Home Assistant中，进入 `设置` → `加载项、备份与监控` → `加载项商店`
2. 找到并点击 `TradingAgents-CN` 加载项
3. 点击 `配置` 标签页
4. 填入获取的API密钥：
```yaml
dashscope_api_key: "您的阿里百炼API密钥（必须）"
tushare_token："您的Tushare API 密钥（必须 推荐用于A股）"
finnhub_api_key: "您的FinnHub API密钥（必须 用于美股）"
google_api_key: "您的Google AI API密钥（可选）"
openai_api_key: "您的OpenAI API密钥（可选）"
anthropic_api_key: "您的Anthropic API密钥（可选）"
```
5. 点击 `保存`
6. 点击 `重新启动` 使配置生效

## 📊 使用教程

### 基础股票分析

#### 1. 访问界面
- 打开浏览器，访问 `http://您的IP:8501`
- 等待界面加载完成


记住：理性投资，风险自控，AI辅助决策而非替代决策。