FROM caddy:2-alpine AS caddy

FROM golang:1.23-alpine AS goreman
ENV CGO_ENABLED=0
ENV GOOS=linux
RUN go install github.com/mattn/goreman@latest

FROM n8nio/n8n:latest

USER root

RUN mkdir -p /opt/bin
COPY --from=caddy /usr/bin/caddy /opt/bin/caddy
COPY --from=goreman /go/bin/goreman /opt/bin/goreman
RUN chmod +x /opt/bin/caddy /opt/bin/goreman

COPY Caddyfile /etc/caddy/Caddyfile
COPY Procfile /Procfile

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]