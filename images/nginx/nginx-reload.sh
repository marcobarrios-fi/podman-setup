#!/bin/sh

# marcobarrios.fi NGINX Reload Shell Script
# /usr/local/bin/nginx-reload
# Reloads the NGINX service to apply new certificates
# Usage: /usr/local/bin/nginx-reload

# Reload NGINX
nginx -s reload;