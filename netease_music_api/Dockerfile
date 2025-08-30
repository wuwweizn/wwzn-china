FROM node:18-alpine

WORKDIR /app

COPY build/NeteaseCloudMusicApiBackup /app

RUN npm install

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 3000

# 添加自定义日志输出
RUN echo "----------------------------------------" && \
    echo "【无为智能】构建加载项" && \
    echo "无为之中，智启未来" && \
    echo "邮箱：wuweizhineng@163.com" && \
    echo "加载项地址：https://gitee.com/wuwzn/ha-addons" && \
    echo "原项目版权归原作者，加载项是在原项目上的基础上的重新构建，方便HA使用" && \
    echo "----------------------------------------"

CMD [ "/run.sh" ]
