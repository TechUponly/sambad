#!/bin/bash
# Fix Nginx WebSocket Connection header
sudo sed -i 's/proxy_set_header Connection $http_upgrade;/proxy_set_header Connection "upgrade";/' /etc/nginx/sites-enabled/web-uponlytech

# Verify
echo "=== VERIFICATION ==="
grep -A 5 "sambad-backend/ws" /etc/nginx/sites-enabled/web-uponlytech | head -8

# Test nginx config
echo "=== NGINX TEST ==="
sudo nginx -t 2>&1

# Reload
echo "=== NGINX RELOAD ==="
sudo systemctl reload nginx 2>&1
echo "Done!"
