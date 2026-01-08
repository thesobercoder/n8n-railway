FROM n8nio/n8n:latest

USER root

# Install Caddy and supervisord
RUN apt-get update && apt-get install -y --no-install-recommends \
    caddy \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Copy config files
COPY Caddyfile /etc/caddy/Caddyfile
COPY supervisord.conf /etc/supervisord.conf

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
