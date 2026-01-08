#!/bin/sh
echo "=== Container starting ==="
echo "Checking binaries..."
ls -la /opt/bin/
echo "Testing goreman..."
/opt/bin/goreman version || echo "goreman failed"
echo "Testing caddy..."
/opt/bin/caddy version || echo "caddy failed"
echo "Starting goreman..."
exec /opt/bin/goreman -f /Procfile start