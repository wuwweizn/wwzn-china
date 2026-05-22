#!/bin/sh
# ============================================================
# OuonnkiTV HA 加载项启动脚本
# 替换 TMDB 占位符后由 supervisord 同时启动 nginx + proxy-server
# ============================================================

OPTIONS="/data/options.json"
DIST="/usr/share/nginx/html"

get_str() {
    jq -r ".$1 // \"\"" "$OPTIONS" 2>/dev/null || echo ""
}

echo "[OuonnkiTV] ===== 启动中 ====="

if [ -f "$OPTIONS" ]; then
    TMDB_TOKEN=$(get_str "oki_tmdb_api_token")
    TMDB_API=$(get_str "oki_tmdb_api_base_url")
    TMDB_IMG=$(get_str "oki_tmdb_image_base_url")

    [ -z "$TMDB_API" ] && TMDB_API="https://api.tmdb.org/3"
    [ -z "$TMDB_IMG" ] && TMDB_IMG="https://image.tmdb.org/t/p/"

    echo "[OuonnkiTV] TMDB Token : $([ -n "$TMDB_TOKEN" ] && echo '已设置' || echo '未设置')"
    echo "[OuonnkiTV] TMDB API   : $TMDB_API"

    escape_sed() {
        printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/[\/&]/\\&/g'
    }

    for JS_FILE in "$DIST"/assets/index-*.js; do
        [ -f "$JS_FILE" ] || continue
        if grep -q "__OKI_TMDB_API_TOKEN__" "$JS_FILE" 2>/dev/null; then
            sed -i \
                -e "s/__OKI_TMDB_API_TOKEN__/$(escape_sed "$TMDB_TOKEN")/g" \
                -e "s/__OKI_TMDB_API_BASE_URL__/$(escape_sed "$TMDB_API")/g" \
                -e "s/__OKI_TMDB_IMAGE_BASE_URL__/$(escape_sed "$TMDB_IMG")/g" \
                "$JS_FILE"
            echo "[OuonnkiTV] ✅ 已注入 TMDB 配置"
        fi
    done
fi

echo "[OuonnkiTV] ===== 启动 supervisord (nginx + proxy-server) ====="
exec /usr/bin/supervisord -c /etc/supervisord.conf