FROM caddy:2-builder AS caddy-builder
RUN xcaddy build

FROM golang:1.21 AS goreman-builder
RUN CGO_ENABLED=0 GOOS=linux go install github.com/mattn/goreman@latest

FROM n8nio/n8n:latest

USER root

# Copy static binaries
COPY --from=caddy-builder /usr/bin/caddy /usr/local/bin/caddy
COPY --from=goreman-builder /go/bin/goreman /usr/local/bin/goreman

# Verify binaries exist
RUN ls -la /usr/local/bin/caddy /usr/local/bin/goreman

# Copy config files
COPY Caddyfile /etc/caddy/Caddyfile
COPY Procfile /Procfile

CMD ["/usr/local/bin/goreman", "-f", "/Procfile", "start"]