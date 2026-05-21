#!/bin/sh
# HA 加载项在 /data/options.json 中存放用户配置
OPTIONS_FILE="/data/options.json"

if [ -f "$OPTIONS_FILE" ]; then
    # 将 options.json 中的配置注入到 nginx 环境（写入 env.js 供前端读取，或直接透传给后端）
    # OuonnkiTV 是纯静态前端，环境变量在 *构建时* 注入，运行时无法动态修改 JS bundle。
    # 因此这里生成一个 /usr/share/nginx/html/runtime-config.json 供前端检测。
    INITIAL_VIDEO_SOURCES=$(cat "$OPTIONS_FILE" | grep -o '"initial_video_sources":"[^"]*"' | cut -d':' -f2- | tr -d '"')
    TMDB_API_TOKEN=$(cat "$OPTIONS_FILE" | grep -o '"tmdb_api_token":"[^"]*"' | cut -d':' -f2- | tr -d '"')
    TMDB_API_BASE_URL=$(cat "$OPTIONS_FILE" | grep -o '"tmdb_api_base_url":"[^"]*"' | cut -d':' -f2- | tr -d '"')
    TMDB_IMAGE_BASE_URL=$(cat "$OPTIONS_FILE" | grep -o '"tmdb_image_base_url":"[^"]*"' | cut -d':' -f2- | tr -d '"')
    ACCESS_PASSWORD=$(cat "$OPTIONS_FILE" | grep -o '"access_password":"[^"]*"' | cut -d':' -f2- | tr -d '"')
    DISABLE_ANALYTICS=$(cat "$OPTIONS_FILE" | grep -o '"disable_analytics":[^,}]*' | cut -d':' -f2 | tr -d ' ')

    cat > /usr/share/nginx/html/runtime-config.json <<EOF
{
  "OKI_INITIAL_VIDEO_SOURCES": "${INITIAL_VIDEO_SOURCES}",
  "OKI_TMDB_API_TOKEN": "${TMDB_API_TOKEN}",
  "OKI_TMDB_API_BASE_URL": "${TMDB_API_BASE_URL}",
  "OKI_TMDB_IMAGE_BASE_URL": "${TMDB_IMAGE_BASE_URL}",
  "OKI_ACCESS_PASSWORD": "${ACCESS_PASSWORD}",
  "OKI_DISABLE_ANALYTICS": ${DISABLE_ANALYTICS:-true}
}
EOF
fi

# 启动 nginx（前台模式）
exec nginx -g "daemon off;"
