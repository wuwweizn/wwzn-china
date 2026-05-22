#!/bin/sh
# ============================================================
# OuonnkiTV HA 加载项启动脚本
# 仅替换 TMDB 相关占位符（运行时可变配置）
# 密码/视频源/初始配置在构建时已设为空字符串，由应用内设置管理
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

    echo "[OuonnkiTV] TMDB Token   : $([ -n "$TMDB_TOKEN" ] && echo '已设置' || echo '未设置')"
    echo "[OuonnkiTV] TMDB API URL : $TMDB_API"
    echo "[OuonnkiTV] TMDB IMG URL : $TMDB_IMG"

    escape_sed() {
        printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/[\/&]/\\&/g'
    }

    for JS_FILE in "$DIST"/assets/index-*.js; do
        [ -f "$JS_FILE" ] || continue

        # 先检查占位符是否存在，不存在说明 Vite 已优化，打印警告
        if grep -q "__OKI_TMDB_API_TOKEN__" "$JS_FILE" 2>/dev/null; then
            sed -i \
                -e "s/__OKI_TMDB_API_TOKEN__/$(escape_sed "$TMDB_TOKEN")/g" \
                -e "s/__OKI_TMDB_API_BASE_URL__/$(escape_sed "$TMDB_API")/g" \
                -e "s/__OKI_TMDB_IMAGE_BASE_URL__/$(escape_sed "$TMDB_IMG")/g" \
                "$JS_FILE"
            echo "[OuonnkiTV] ✅ 已注入 TMDB 配置: $(basename "$JS_FILE")"
        else
            echo "[OuonnkiTV] ⚠️  $(basename "$JS_FILE") 中未找到占位符，TMDB 配置需在应用内手动设置"
        fi
    done
else
    echo "[OuonnkiTV] ⚠️  未找到 options.json，跳过配置注入"
fi

echo "[OuonnkiTV] ===== 启动 nginx ====="
exec nginx -g "daemon off;"