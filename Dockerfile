FROM n8nio/n8n:latest

USER root

# Install Caddy and supervisord
RUN apk add --no-cache caddy supervisor

# Copy config files
COPY Caddyfile /etc/caddy/Caddyfile
COPY supervisord.conf /etc/supervisord.conf

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
