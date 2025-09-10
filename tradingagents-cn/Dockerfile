ARG BUILD_FROM
FROM $BUILD_FROM

# 安装基础依赖
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 安装Streamlit
RUN pip3 install streamlit

# 创建应用目录和文件
WORKDIR /opt/app
RUN mkdir -p /data

# 创建简单应用
RUN cat > app.py <<EOF && \
import streamlit as st
st.title("TradingAgents-CN 测试页面")
st.success("如果您能看到这个页面，说明基础环境已经正常工作！")
st.info("接下来可以添加完整功能。")
EOF

# 创建启动脚本
RUN cat > start.sh <<'EOF' && \
#!/bin/bash
echo "Starting TradingAgents-CN test..."
cd /opt/app
exec python3 -m streamlit run app.py --server.address 0.0.0.0 --server.port 8501 --server.headless true
EOF

RUN chmod +x start.sh

EXPOSE 8501

CMD ["./start.sh"]