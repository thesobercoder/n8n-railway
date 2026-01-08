FROM caddy:2-alpine AS caddy

FROM golang:1.21-alpine AS goreman
# Static binary - no libc dependency
ENV CGO_ENABLED=0
ENV GOOS=linux
RUN go install github.com/mattn/goreman@latest
# Verify in builder
RUN ls -la /go/bin/ && /go/bin/goreman version

FROM n8nio/n8n:latest

USER root

# Copy binaries
COPY --from=caddy /usr/bin/caddy /usr/local/bin/caddy
COPY --from=goreman /go/bin/goreman /usr/local/bin/goreman

# Make executable
RUN chmod +x /usr/local/bin/caddy /usr/local/bin/goreman

# Verify binaries work in final image - build fails here if broken
RUN /usr/local/bin/goreman version
RUN /usr/local/bin/caddy version

# Copy config files
COPY Caddyfile /etc/caddy/Caddyfile
COPY Procfile /Procfile

CMD ["/usr/local/bin/goreman", "-f", "/Procfile", "start"]