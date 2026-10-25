#!/bin/sh

# marcobarrios.fi Certbot Initialization Shell Script
# /usr/local/bin/certbot-init

### Directories
# Mounted volumes are not available at the build time

# Create data directory
mkdir -p "$DATA_DIR";

if test -n "$LOG_DIR"; then
  # Create log directory
  mkdir -p "$LOG_DIR";
fi

# Create SSL keys directory
mkdir -p "$SSL_KEYS_DIR";

# Create SSL certificates directory
mkdir -p "$SSL_CERTS_DIR";

### Cloudflare configuration

if test -s '/run/secrets/cloudflare-api-token'; then
  # Set Cloudflare API token environment variable
  export CLOUDFLARE_API_TOKEN="$(cat '/run/secrets/cloudflare-api-token')";
else
  echo 'Warning: Cloudflare API token secret is not specified' > '/dev/stderr';
fi

if test -f '/tmp/cloudflare-dns-template.ini'; then
  # Create Cloudflare DNS configuration file from the configuration template
  envsubst < '/tmp/cloudflare-dns-template.ini' > "$CLOUDFLARE_CONFIG";
  # Set Cloudflare DNS configuration file permissions
  # (suppresses "Unsafe permissions on credentials configuration file" warning messages)
  chmod 600 "$CLOUDFLARE_CONFIG";
  # Delete configuration template
  rm '/tmp/cloudflare-dns-template.ini';
fi

### DigitalOcean configuration

if test -s '/run/secrets/digitalocean-api-token'; then
  # Set DigitalOcean API token environment variable
  export DIGITALOCEAN_API_TOKEN="$(cat '/run/secrets/digitalocean-api-token')";
else
  echo 'Warning: DigitalOcean API token secret is not specified' > '/dev/stderr';
fi

if test -f '/tmp/digitalocean-dns-template.ini'; then
  # Create DigitalOcean DNS configuration file from the configuration template
  envsubst < '/tmp/digitalocean-dns-template.ini' > "$DIGITALOCEAN_CONFIG";
  # Set DigitalOcean DNS configuration file permissions
  # (suppresses "Unsafe permissions on credentials configuration file" warning messages)
  chmod 600 "$DIGITALOCEAN_CONFIG";
  # Delete configuration template
  rm '/tmp/digitalocean-dns-template.ini';
fi

# Start Certbot
certbot-exec;

# Keep the container running indefinitely
# (necessary for keeping the container alive for scheduled tasks)
exec sleep infinity;