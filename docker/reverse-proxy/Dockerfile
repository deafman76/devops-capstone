FROM nginxinc/nginx-unprivileged:alpine

COPY docker/reverse-proxy/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD wget -q -O - http://127.0.0.1:8080/ || exit 1
