FROM caddy:2-alpine AS caddy

FROM golang:1.23-alpine AS goreman
ENV CGO_ENABLED=0
ENV GOOS=linux
RUN go install github.com/mattn/goreman@latest
RUN /go/bin/goreman version

FROM n8nio/n8n:latest

USER root

COPY --from=caddy /usr/bin/caddy /usr/local/bin/caddy
COPY --from=goreman /go/bin/goreman /usr/local/bin/goreman

RUN chmod +x /usr/local/bin/caddy /usr/local/bin/goreman
RUN /usr/local/bin/goreman version
RUN /usr/local/bin/caddy version

COPY Caddyfile /etc/caddy/Caddyfile
COPY Procfile /Procfile

CMD ["/usr/local/bin/goreman", "-f", "/Procfile", "start"]