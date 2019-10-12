FROM alpine:latest

RUN apk update && apk add --no-cache nginx

RUN mkdir -p /run/nginx

COPY default.conf /etc/nginx/conf.d/default.conf

ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]