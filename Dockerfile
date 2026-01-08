FROM caddy:2-alpine AS caddy

FROM n8nio/n8n:latest

USER root

# Copy Caddy binary from caddy image
COPY --from=caddy /usr/bin/caddy /usr/local/bin/caddy

# Install supervisor via pip
RUN pip install --no-cache-dir supervisor

# Copy config files
COPY Caddyfile /etc/caddy/Caddyfile
COPY supervisord.conf /etc/supervisord.conf

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
