docker run --name nginx -d \
-p 5600:82 \
-v /root/work/nginx/demo:/usr/local/nginx/html \
-v /root/work/nginx/conf/nginx.conf:/usr/local/nginx/conf/nginx.conf \
-v /root/work/nginx/logs/:/usr/local/nginx/logs \
mogezi/nginx:0.3