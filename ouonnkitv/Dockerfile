# ============================================================
# 构建阶段：固定 amd64，避免 lightningcss 等原生模块在 armv7
# 无预编译二进制时的编译失败问题。
# ============================================================
FROM --platform=linux/amd64 node:20-alpine AS builder

# 视频源：构建时直接硬编码，启动即可用
ENV OKI_INITIAL_VIDEO_SOURCES='[{"id":"iqiyizyapi-com","name":"爱奇艺","url":"https://iqiyizyapi.com/api.php/provide/vod","detailUrl":"https://iqiyizyapi.com","isEnabled":true},{"id":"dbzy-tv","name":"豆瓣资源","url":"https://caiji.dbzy5.com/api.php/provide/vod","detailUrl":"https://dbzy.tv","isEnabled":true},{"id":"ikunzy-com","name":"iKun资源","url":"https://ikunzyapi.com/api.php/provide/vod","detailUrl":"https://ikunzy.com","isEnabled":true},{"id":"www-maoyanzy-com","name":"猫眼资源","url":"https://api.maoyanapi.top/api.php/provide/vod","detailUrl":"https://www.maoyanzy.com","isEnabled":true},{"id":"360zy-com","name":"360资源","url":"https://360zyzz.com/api.php/provide/vod","detailUrl":"https://360zy.com","isEnabled":true},{"id":"www-moduzy-net","name":"魔都资源","url":"https://www.mdzyapi.com/api.php/provide/vod","detailUrl":"https://www.moduzy.net","isEnabled":true},{"id":"xinlangapi-com","name":"新浪资源","url":"https://api.xinlangapi.com/xinlangapi.php/provide/vod","detailUrl":"https://xinlangapi.com","isEnabled":true},{"id":"www-subozy-com","name":"速播资源","url":"https://subocaiji.com/api.php/provide/vod","detailUrl":"https://www.subozy.com","isEnabled":true},{"id":"jinyingzy-com","name":"金鹰点播","url":"https://jinyingzy.com/api.php/provide/vod","detailUrl":"https://jinyingzy.com","isEnabled":true},{"id":"api-guangsuapi-com","name":"光速资源","url":"https://api.guangsuapi.com/api.php/provide/vod","detailUrl":"https://api.guangsuapi.com","isEnabled":true},{"id":"www-hongniuzy-com","name":"红牛资源","url":"https://www.hongniuzy2.com/api.php/provide/vod","detailUrl":"https://www.hongniuzy.com","isEnabled":true},{"id":"caiji-moduapi-cc","name":"魔都动漫","url":"https://caiji.moduapi.cc/api.php/provide/vod","detailUrl":"https://caiji.moduapi.cc","isEnabled":true},{"id":"www-ryzyw-com","name":"如意资源","url":"https://cj.rycjapi.com/api.php/provide/vod","detailUrl":"https://www.ryzyw.com","isEnabled":true},{"id":"www-haohuazy-com","name":"豪华资源","url":"https://hhzyapi.com/api.php/provide/vod","detailUrl":"https://www.haohuazy.com","isEnabled":true},{"id":"www-huyaapi-com","name":"虎牙资源","url":"https://www.huyaapi.com/api.php/provide/vod","detailUrl":"https://www.huyaapi.com","isEnabled":true}]'

ENV OKI_ACCESS_PASSWORD=""
ENV OKI_INITIAL_CONFIG=""
ENV OKI_DISABLE_ANALYTICS="true"

# TMDB 配置：用占位符，运行时由 run.sh 替换
ENV OKI_TMDB_API_TOKEN="__OKI_TMDB_API_TOKEN__"
ENV OKI_TMDB_API_BASE_URL="__OKI_TMDB_API_BASE_URL__"
ENV OKI_TMDB_IMAGE_BASE_URL="__OKI_TMDB_IMAGE_BASE_URL__"

RUN apk add --no-cache git && \
    git clone --depth=1 https://github.com/Ouonnki/OuonnkiTV /build

WORKDIR /build

RUN npm install -g pnpm && \
    pnpm install && \
    pnpm build

# ============================================================
# 运行阶段
# ============================================================
FROM nginx:alpine

ARG BUILD_ARCH=amd64

LABEL \
  io.hass.name="OuonnkiTV" \
  io.hass.description="一键搭建个人影视站，支持TMDB智能模式，基于LibreTV修改" \
  io.hass.arch="${BUILD_ARCH}" \
  io.hass.type="addon" \
  maintainer="wuwweizn"

RUN apk add --no-cache jq

RUN printf 'server {\n\
    listen 17380;\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
    location / {\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
}\n' > /etc/nginx/conf.d/default.conf

COPY --from=builder /build/dist /usr/share/nginx/html
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 17380

CMD ["/run.sh"]