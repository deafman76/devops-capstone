FROM nginxinc/nginx-unprivileged:alpine

COPY app/index.html /usr/share/nginx/html/index.html
COPY app/health.html /usr/share/nginx/html/health.html
COPY app/version.json /usr/share/nginx/html/version.json

COPY docker/nginx-app.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD wget -q -O - http://127.0.0.1:8080/health.html || exit 1
