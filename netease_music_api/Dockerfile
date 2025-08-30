FROM node:18-alpine

WORKDIR /app

# 复制你的项目文件到容器中
COPY build/NeteaseCloudMusicApiBackup /app

# 安装应用依赖
RUN npm install

# 复制 config.json 配置文件
COPY config.json /app/config.json

# 输出日志信息到标准输出
RUN echo "----------------------------------------" && \
    echo "【无为智能】构建加载项" && \
    echo "无为之中，智启未来" && \
    echo "邮箱：wuweizhineng@163.com" && \
    echo "加载项地址：https://gitee.com/wuwzn/ha-addons" && \
    echo "原项目版权归原作者，加载项是在原项目上的基础上的重新构建，方便HA使用" && \
    echo "----------------------------------------"

# 启动应用
CMD ["npm", "start"]
