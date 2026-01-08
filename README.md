# n8n with Caddy Reverse Proxy

Fixes Cloudflare SSE buffering issues for MCP endpoints by injecting `X-Accel-Buffering: no` header.

## Problem

Cloudflare's reverse proxy buffers SSE (Server-Sent Events) responses, breaking MCP connections. This setup adds Caddy as a reverse proxy that injects the header telling Cloudflare to disable buffering.

## Architecture
```
Internet → Cloudflare (orange) → Railway → Caddy (:$PORT) → n8n (:5678)
                                              │
                                   Injects X-Accel-Buffering: no
```

## Port Configuration

| Component | Port | Exposed | Description |
|-----------|------|---------|-------------|
| Caddy | `$PORT` | ✅ Yes | Railway-assigned. Public-facing. |
| n8n | `5678` | ❌ No | Internal only. Caddy proxies to it. |

## Files
```
.
├── Dockerfile          # n8n + Caddy + supervisord
├── Caddyfile           # Reverse proxy config
├── supervisord.conf    # Process manager config
└── README.md
```

## Deployment

### 1. Create Railway Service
```bash
# Clone/create repo with these files
git init
git add Dockerfile Caddyfile supervisord.conf README.md
git commit -m "n8n with Caddy proxy"

# Connect to Railway via dashboard or CLI
railway link
railway up
```

### 2. Environment Variables

Set in Railway dashboard:
```bash
# Required
WEBHOOK_URL=https://your-domain.com
N8N_PROTOCOL=https
N8N_HOST=0.0.0.0

# Optional
GENERIC_TIMEZONE=Asia/Kolkata
N8N_ENCRYPTION_KEY=<your-key>
N8N_USER_MANAGEMENT_JWT_SECRET=<your-secret>

# Database (if using external)
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=<host>
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=<user>
DB_POSTGRESDB_PASSWORD=<password>
```

### 3. Custom Domain

1. Railway → Service → Settings → Networking → Custom Domain
2. Add: `n8n.yourdomain.com`
3. Copy Railway's CNAME/A record

### 4. Cloudflare DNS

| Type | Name | Content | Proxy |
|------|------|---------|-------|
| CNAME | n8n | railway-provided-value | ✅ Proxied (orange) |

### 5. Cloudflare Page Rule (Optional)

For `/mcp/*` path:
- Cache Level: Bypass
- Rocket Loader: Off

## Verification

Test header injection:
```bash
curl -I https://n8n.yourdomain.com/mcp/your-uuid | grep -i accel
```

Expected output:
```
x-accel-buffering: no
```

Test MCP connection:
1. Add MCP server in Claude Desktop/Code
2. URL: `https://n8n.yourdomain.com/mcp/your-uuid`
3. Should connect without auth errors

## Process Management

Supervisord manages both processes:

| Process | Auto-restart | Signal Handling |
|---------|--------------|-----------------|
| n8n | ✅ Yes | ✅ SIGTERM propagated |
| Caddy | ✅ Yes | ✅ SIGTERM propagated |

View logs in Railway dashboard - both processes log to stdout.

## Endpoints with SSE Header

The `X-Accel-Buffering: no` header is injected for:

- `/mcp/*` - MCP server endpoints
- `/rest/push/*` - n8n UI push updates

All other routes proxied normally without header modification.

## Troubleshooting

### MCP still not connecting

1. Verify header: `curl -I https://your-domain/mcp/...`
2. Check Cloudflare is proxied (orange cloud)
3. Check Railway logs for errors

### 502 Bad Gateway

n8n hasn't started yet. Caddy starts faster than n8n (~30s). Wait and retry.

### Container keeps restarting

Check Railway logs. Common issues:
- Missing env vars
- Database connection failed
- Port conflict

### Logs not showing

Ensure `stdout_logfile=/dev/stdout` in supervisord.conf (not a file path).

## Local Testing
```bash
# Build
docker build -t n8n-caddy .

# Run (simulating Railway's PORT injection)
docker run -e PORT=8080 -e N8N_HOST=0.0.0.0 -p 8080:8080 n8n-caddy

# Test
curl -I http://localhost:8080/mcp/test
```

## Updates

To update n8n version, rebuild:
```bash
docker build --no-cache -t n8n-caddy .
railway up
```

Or trigger redeploy in Railway dashboard.

## License

MIT
