FROM node:18-alpine

WORKDIR /app

# 复制项目源代码到容器中
COPY build/NeteaseCloudMusicApiBackup /app

# 安装 Node.js 依赖
RUN npm install

# 复制 run.sh 脚本到容器中
COPY run.sh /run.sh
RUN chmod +x /run.sh

# 设置容器暴露的端口
EXPOSE 3000

# 添加自定义日志输出（在容器启动时输出）
RUN echo "----------------------------------------" && \
    echo "【无为智能】构建加载项" && \
    echo "无为之中，智启未来" && \
    echo "邮箱：wuweizhineng@163.com" && \
    echo "加载项地址：https://gitee.com/wuwzn/ha-addons" && \
    echo "原项目版权归原作者，加载项是在原项目上的基础上的重新构建，方便HA使用" && \
    echo "----------------------------------------"

# 使用 run.sh 脚本启动应用
CMD ["/run.sh"]
