#!/bin/sh

# marcobarrios.fi Certbot Exec Shell Script
# /usr/local/bin/certbot-exec
# Renews Let's Encrypt SSL certificates
# https://eff-certbot.readthedocs.io/en/stable/using.html

# Notice that generating the certificate using DNS plugins failed with the default 10 second propagation time

# Disable logging if log directory is not set
if test -z "$LOG_DIR"; then
  LOG_DIR='/dev/null';
fi

### Cloudflare SSL certificates

# Renew SSL certificates for Cloudflare domains
if test -n "$CLOUDFLARE_DOMAINS"; then
  for domain in $CLOUDFLARE_DOMAINS; do
    echo "Renewing SSL certificate for $domain using Cloudflare API";
    certbot certonly \
    --non-interactive \
    --agree-tos \
    --email "$ACCOUNT_EMAIL_ADDRESS" \
    --dns-cloudflare \
    --dns-cloudflare-credentials "$CLOUDFLARE_CONFIG" \
    --dns-cloudflare-propagation-seconds 30 \
    --domains "$domain,*.$domain" \
    --deploy-hook certbot-deploy \
    --verbose \
    --logs-dir "$LOG_DIR";
  done
fi

### DigitalOcean SSL certificates

# Renew SSL certificates for DigitalOcean domains
if test -n "$DIGITALOCEAN_DOMAINS"; then
  for domain in $DIGITALOCEAN_DOMAINS; do
    echo "Renewing SSL certificate for $domain using DigitalOcean API";
    certbot certonly \
    --non-interactive \
    --agree-tos \
    --email "$ACCOUNT_EMAIL_ADDRESS" \
    --dns-digitalocean \
    --dns-digitalocean-credentials "$DIGITALOCEAN_CONFIG" \
    --dns-digitalocean-propagation-seconds 30 \
    --domains "$domain,*.$domain" \
    --deploy-hook certbot-deploy \
    --verbose \
    --logs-dir "$LOG_DIR";
  done
fi