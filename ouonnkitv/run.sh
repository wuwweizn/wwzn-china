#!/bin/sh
# ============================================================
# OuonnkiTV HA 加载项启动脚本
# 从 /data/options.json 读取用户配置，
# 用 sed 替换 JS bundle 里的占位符，实现运行时注入。
# ============================================================

OPTIONS="/data/options.json"
DIST="/usr/share/nginx/html"

# 读取配置值，不存在则取默认
get_opt() {
    local key="$1"
    local default="$2"
    local val
    val=$(jq -r ".${key} // empty" "$OPTIONS" 2>/dev/null)
    [ -z "$val" ] && val="$default"
    echo "$val"
}

if [ -f "$OPTIONS" ]; then
    SOURCES=$(get_opt "oki_initial_video_sources" "")
    TMDB_TOKEN=$(get_opt "oki_tmdb_api_token" "")
    TMDB_API=$(get_opt "oki_tmdb_api_base_url" "https://api.tmdb.org/3")
    TMDB_IMG=$(get_opt "oki_tmdb_image_base_url" "https://image.tmdb.org/t/p/")
    PASSWORD=$(get_opt "oki_access_password" "")
    DISABLE_ANALYTICS=$(get_opt "oki_disable_analytics" "true")
    INITIAL_CONFIG=$(get_opt "oki_initial_config" "")

    echo "[OuonnkiTV] 正在注入配置..."

    # 找到 JS bundle（Vite 构建产物文件名含 hash，用 glob 匹配）
    for JS_FILE in "$DIST"/assets/index-*.js; do
        [ -f "$JS_FILE" ] || continue

        # 转义替换值中的特殊字符（/, &, \）防止 sed 报错
        escape() { printf '%s' "$1" | sed 's/[\/&]/\\&/g'; }

        sed -i \
            -e "s/__OKI_INITIAL_VIDEO_SOURCES__/$(escape "$SOURCES")/g" \
            -e "s/__OKI_TMDB_API_TOKEN__/$(escape "$TMDB_TOKEN")/g" \
            -e "s/__OKI_TMDB_API_BASE_URL__/$(escape "$TMDB_API")/g" \
            -e "s/__OKI_TMDB_IMAGE_BASE_URL__/$(escape "$TMDB_IMG")/g" \
            -e "s/__OKI_ACCESS_PASSWORD__/$(escape "$PASSWORD")/g" \
            -e "s/__OKI_DISABLE_ANALYTICS__/$(escape "$DISABLE_ANALYTICS")/g" \
            -e "s/__OKI_INITIAL_CONFIG__/$(escape "$INITIAL_CONFIG")/g" \
            "$JS_FILE"

        echo "[OuonnkiTV] 已注入: $(basename "$JS_FILE")"
    done

    echo "[OuonnkiTV] 配置注入完成，启动 nginx..."
else
    echo "[OuonnkiTV] 未找到 options.json，使用空默认值启动..."
fi

exec nginx -g "daemon off;"
