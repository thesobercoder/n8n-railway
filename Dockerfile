FROM caddy:2-alpine AS caddy

FROM golang:1.23-alpine AS goreman
ENV CGO_ENABLED=0
ENV GOOS=linux
RUN go install github.com/mattn/goreman@latest

FROM n8nio/n8n:latest

USER root

# Copy to /opt/bin instead - won't be overwritten by volumes
RUN mkdir -p /opt/bin
COPY --from=caddy /usr/bin/caddy /opt/bin/caddy
COPY --from=goreman /go/bin/goreman /opt/bin/goreman

RUN chmod +x /opt/bin/caddy /opt/bin/goreman
RUN /opt/bin/goreman version
RUN /opt/bin/caddy version

COPY Caddyfile /etc/caddy/Caddyfile
COPY Procfile /Procfile

CMD ["/opt/bin/goreman", "-f", "/Procfile", "start"]