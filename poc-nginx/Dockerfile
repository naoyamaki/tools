FROM openresty/openresty:alpine

ENV WAIT_SEC=5
ENV ERR_PCT=50

COPY html/index.html /usr/local/openresty/nginx/html/index.html
COPY nginx/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
