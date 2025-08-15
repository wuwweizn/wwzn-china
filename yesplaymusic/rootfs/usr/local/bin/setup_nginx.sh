# =============================================================================
# rootfs/usr/local/bin/setup_nginx.sh  
# =============================================================================
#!/bin/bash

# 使用环境变量或默认值
NETEASE_API_URL="${NETEASE_API_URL:-https://music-api.hankqin.com}"
SSL="${SSL:-false}"
CERTFILE="${CERTFILE:-fullchain.pem}"
KEYFILE="${KEYFILE:-privkey.pem}"

echo "Configuring Nginx..."
echo "SSL enabled: ${SSL}"
echo "API URL: ${NETEASE_API_URL}"

# 创建nginx配置
cat > /etc/nginx/nginx.conf << EOF
user nginx;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log warn;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 100M;

    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;

    server {
EOF

# SSL配置
if [ "${SSL}" = "true" ]; then
    cat >> /etc/nginx/nginx.conf << EOF
        listen 80 ssl http2;
        ssl_certificate /ssl/${CERTFILE};
        ssl_certificate_key /ssl/${KEYFILE};
        ssl_session_cache shared:SSL:1m;
        ssl_session_timeout 10m;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;
EOF
else
    cat >> /etc/nginx/nginx.conf << EOF
        listen 80;
EOF
fi

# 添加server配置的其余部分
# 创建nginx配置
cat > /etc/nginx/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log warn;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 100M;

    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;

    server {
EOF

# SSL配置
if [ "${SSL}" = "true" ]; then
    cat >> /etc/nginx/nginx.conf << 'EOF'
        listen 80 ssl http2;
        ssl_certificate /ssl/${CERTFILE};
        ssl_certificate_key /ssl/${KEYFILE};
        ssl_session_cache shared:SSL:1m;
        ssl_session_timeout 10m;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;
EOF
else
    cat >> /etc/nginx/nginx.conf << 'EOF'
        listen 80;
EOF
fi

# 添加server配置的其余部分
cat >> /etc/nginx/nginx.conf << 'EOF'
        server_name _;
        
        root /var/www/html;
        index index.html;

        # API代理到网易云音乐API
        location /api/ {
            proxy_pass https://music-api.hankqin.com/;
            proxy_set_header Host music-api.hankqin.com;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header User-Agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36";
            proxy_set_header Referer "https://music-api.hankqin.com";
            proxy_set_header Origin "https://music-api.hankqin.com";
            
            # SSL相关
            proxy_ssl_verify off;
            proxy_ssl_server_name on;
            
            # 超时设置
            proxy_connect_timeout 30s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;
            
            # CORS headers
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
            add_header 'Access-Control-Allow-Credentials' 'true' always;
            
            # Handle preflight requests
            if ($request_method = 'OPTIONS') {
                add_header 'Access-Control-Allow-Origin' '*';
                add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS';
                add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization';
                add_header 'Access-Control-Max-Age' 1728000;
                add_header 'Content-Type' 'text/plain; charset=utf-8';
                add_header 'Content-Length' 0;
                return 204;
            }
        }

        # 静态文件服务
        location / {
            try_files $uri $uri/ /index.html;
            
            # 设置正确的MIME类型
            location ~* \.(?:manifest|appcache|html?|xml|json)$ {
                expires -1;
                add_header Cache-Control "no-cache, no-store, must-revalidate";
            }
            
            # 缓存静态资源
            location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
                expires 1y;
                add_header Cache-Control "public, immutable";
                add_header Access-Control-Allow-Origin "*";
            }
            
            # 特殊处理字体文件
            location ~* \.(woff|woff2|ttf|eot)$ {
                add_header Access-Control-Allow-Origin "*";
            }
        }
        
        # 错误页面
        error_page 404 /index.html;
        error_page 500 502 503 504 /index.html;

        # 安全头
        add_header X-Content-Type-Options nosniff;
        add_header X-Frame-Options SAMEORIGIN;
        add_header X-XSS-Protection "1; mode=block";
        add_header Referrer-Policy "strict-origin-when-cross-origin";
    }
}
EOF

echo "Nginx configuration created successfully"

# 测试nginx配置文件
echo "Testing nginx configuration..."
if ! nginx -t; then
    echo "❌ Nginx configuration test failed!"
    echo "Config file content:"
    cat /etc/nginx/nginx.conf
    echo "Creating minimal working config..."
    
    # 创建最小化的nginx配置
    cat > /etc/nginx/nginx.conf << 'MINIMAL_EOF'
user nginx;
worker_processes 1;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    server {
        listen 80;
        server_name _;
        root /var/www/html;
        index index.html;
        
        location / {
            try_files $uri $uri/ /index.html;
        }
        
        location /api/ {
            proxy_pass https://music-api.hankqin.com/;
            proxy_set_header Host music-api.hankqin.com;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        }
    }
}
MINIMAL_EOF
    
    # 再次测试
    if ! nginx -t; then
        echo "❌ Even minimal config failed! Using absolute minimal config..."
        cat > /etc/nginx/nginx.conf << 'ABSOLUTE_MINIMAL_EOF'
events { worker_connections 1024; }
http {
    server {
        listen 80;
        root /var/www/html;
        index index.html;
        location / { try_files $uri /index.html; }
    }
}
ABSOLUTE_MINIMAL_EOF
    fi
fi

echo "Final nginx configuration test:"
nginx -t