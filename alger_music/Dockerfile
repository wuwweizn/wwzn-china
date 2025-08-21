FROM nginx:alpine
COPY ./web /usr/share/nginx/html
RUN echo 'server {     listen 80;     server_name localhost;     root /usr/share/nginx/html;     index index.html;     location / {         try_files $uri /index.html;     } }' > /etc/nginx/conf.d/default.conf
