ARG BUILD_FROM
FROM ${BUILD_FROM}

# 设置环境变量
ENV LANG=C.UTF-8

# 安装必要的依赖
RUN apk add --no-cache \
    nginx \
    git \
    && rm -rf /var/cache/apk/*

# 克隆 Solara 项目
RUN git clone https://github.com/akudamatata/Solara.git /tmp/solara

# 创建 web 目录并复制文件
RUN mkdir -p /var/www/html && \
    cp -r /tmp/solara/* /var/www/html/ && \
    rm -rf /tmp/solara

# 创建数据目录
RUN mkdir -p /data /config

# 复制 nginx 配置
COPY nginx.conf /etc/nginx/nginx.conf

# 复制启动脚本
COPY run.sh /
RUN chmod a+x /run.sh

WORKDIR /var/www/html

# 暴露端口
EXPOSE 3100

CMD ["/run.sh"]