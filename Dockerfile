FROM n8nio/n8n:latest

USER root

# Install Caddy (static binary)
RUN curl -fsSL https://caddyserver.com/api/download?os=linux&arch=amd64 -o /usr/local/bin/caddy \
    && chmod +x /usr/local/bin/caddy

# Install supervisord via pip (Python available in n8n image)
RUN pip install --no-cache-dir supervisor

# Copy config files
COPY Caddyfile /etc/caddy/Caddyfile
COPY supervisord.conf /etc/supervisord.conf

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
