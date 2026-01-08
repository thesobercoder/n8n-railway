FROM caddy:2-alpine AS caddy

FROM golang:alpine AS goreman
RUN go install github.com/mattn/goreman@latest

FROM n8nio/n8n:latest

USER root

# Copy binaries
COPY --from=caddy /usr/bin/caddy /usr/local/bin/caddy
COPY --from=goreman /go/bin/goreman /usr/local/bin/goreman

# Copy config files
COPY Caddyfile /etc/caddy/Caddyfile
COPY Procfile /app/Procfile

WORKDIR /app

CMD ["goreman", "start"]