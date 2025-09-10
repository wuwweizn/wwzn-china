#!/usr/bin/with-contenv bashio
set -e


bashio::log.info "Generating /app/.env from add-on options"
: > /app/.env


append_env() {
local key="$1"; local val
if bashio::config.has_value "$key"; then
val=$(bashio::config "$key")
if [ -n "$val" ]; then
echo "${key^^}=$val" >> /app/.env
fi
fi
}


append_env openai_api_key
append_env deepseek_api_key
append_env gemini_api_key
append_env qwen_api_key
append_env tavily_api_key


# 额外自定义变量（FOO=bar 格式）
if bashio::config.has_value 'other_env'; then
for kv in $(bashio::config 'other_env[]'); do
echo "$kv" >> /app/.env
done
fi


bashio::log.info "Final /app/.env:"
sed 's/=.*/=****/g' /app/.env | xargs -I{} bashio::log.info {}