#!/bin/sh
# ============================================================
# OuonnkiTV HA 加载项启动脚本
# 从 /data/options.json 读取用户配置，
# 用 sed 替换 JS bundle 里的占位符，实现运行时注入。
# ============================================================

OPTIONS="/data/options.json"
DIST="/usr/share/nginx/html"

# 读取字符串型配置，缺失或 null 返回空字符串
get_str() {
    jq -r ".$1 // \"\"" "$OPTIONS" 2>/dev/null || echo ""
}

# 读取布尔型配置，缺失时返回第二参数默认值
# jq 对 false 不能用 // 判空，需单独处理
get_bool() {
    local val
    val=$(jq -r ".$1 | if . == null then \"$2\" else tostring end" "$OPTIONS" 2>/dev/null)
    [ -z "$val" ] && val="$2"
    echo "$val"
}

# 转义 sed 替换值中的特殊字符（/, &, \, 换行）
escape_sed() {
    printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/[\/&]/\\&/g' -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g'
}

# 执行单个占位符替换，占位符不存在时安静跳过
replace_placeholder() {
    local file="$1"
    local placeholder="$2"
    local value="$3"
    sed -i "s/${placeholder}/$(escape_sed "$value")/g" "$file"
}

# ---- 读取所有配置 ----
SOURCES=$(get_str "oki_initial_video_sources")
TMDB_TOKEN=$(get_str "oki_tmdb_api_token")
TMDB_API=$(get_str "oki_tmdb_api_base_url")
TMDB_IMG=$(get_str "oki_tmdb_image_base_url")
PASSWORD=$(get_str "oki_access_password")
DISABLE_ANALYTICS=$(get_bool "oki_disable_analytics" "true")
INITIAL_CONFIG=$(get_str "oki_initial_config")

# 空值回退默认
[ -z "$TMDB_API" ]  && TMDB_API="https://api.tmdb.org/3"
[ -z "$TMDB_IMG" ]  && TMDB_IMG="https://image.tmdb.org/t/p/"

echo "[OuonnkiTV] ===== 配置注入开始 ====="
echo "[OuonnkiTV] TMDB Token   : $([ -n "$TMDB_TOKEN" ] && echo '已设置' || echo '未设置')"
echo "[OuonnkiTV] TMDB API URL : $TMDB_API"
echo "[OuonnkiTV] 访问密码     : $([ -n "$PASSWORD" ] && echo '已设置' || echo '未设置（公开访问）')"
echo "[OuonnkiTV] 禁用统计     : $DISABLE_ANALYTICS"
echo "[OuonnkiTV] 视频源       : $([ -n "$SOURCES" ] && echo '已设置' || echo '未设置')"
echo "[OuonnkiTV] 完整配置     : $([ -n "$INITIAL_CONFIG" ] && echo '已设置' || echo '未设置')"

# ---- 对所有 JS bundle 执行占位符替换 ----
REPLACED=0
for JS_FILE in "$DIST"/assets/index-*.js; do
    [ -f "$JS_FILE" ] || continue

    replace_placeholder "$JS_FILE" "__OKI_INITIAL_VIDEO_SOURCES__" "$SOURCES"
    replace_placeholder "$JS_FILE" "__OKI_TMDB_API_TOKEN__"        "$TMDB_TOKEN"
    replace_placeholder "$JS_FILE" "__OKI_TMDB_API_BASE_URL__"     "$TMDB_API"
    replace_placeholder "$JS_FILE" "__OKI_TMDB_IMAGE_BASE_URL__"   "$TMDB_IMG"
    replace_placeholder "$JS_FILE" "__OKI_ACCESS_PASSWORD__"       "$PASSWORD"
    replace_placeholder "$JS_FILE" "__OKI_DISABLE_ANALYTICS__"     "$DISABLE_ANALYTICS"
    replace_placeholder "$JS_FILE" "__OKI_INITIAL_CONFIG__"        "$INITIAL_CONFIG"

    echo "[OuonnkiTV] 已注入: $(basename "$JS_FILE")"
    REPLACED=$((REPLACED + 1))
done

if [ "$REPLACED" -eq 0 ]; then
    echo "[OuonnkiTV] ⚠️  未找到 JS bundle，请确认镜像构建正常"
else
    echo "[OuonnkiTV] ✅ 共注入 $REPLACED 个 JS 文件"
fi

echo "[OuonnkiTV] ===== 启动 nginx ====="
exec nginx -g "daemon off;"