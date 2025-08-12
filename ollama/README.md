＃家庭助理的ollama addon

请注意，此插件以CPU加速度或实验性NVIDIA GPU支持运行（如果它对您有用，请报告！）。对于ROCM，支持仍在等待。
##模型目录

默认情况下，所有下载的型号均存储`/share/ollama`。由于历史原因，您还可以为`/config/ollama“配置它。请确保您有足够的空间。
## Ollama Integration

要下载任何模型使用Ollama的API或与Home Assistant Integration [Ollama]集成（https://www.home-assistant.io/integrations/ollama/）：
[![Add Ollama Integration](https://my.home-assistant.io/badges/brand.svg)](https://my.home-assistant.io/redirect/config_flow_start/?domain=ollama)

使用以下数据：

- URL: `http://76e18fb5-ollama:11434`

如果要更改模型，请删除集成（而不是插件！），然后重新启动集成配置的过程。
##在UI链接上注释

UI链接仅在那里检查Ollama的API是否可用。 Ollama的官方形象中没有聊天功能。