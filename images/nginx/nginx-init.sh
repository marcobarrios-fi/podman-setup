#!/bin/sh

# marcobarrios.fi NGINX Initialization Shell Script
# /usr/local/bin/nginx-init

# The initialization script is executed every time the container is started
# Custom data in the sites directory will be deleted every time the container is started

### Directories
# Mounted volumes are not available at the build time

# Create data directory
mkdir -p "$DATA_DIR";

# Create hosts configuration directory
mkdir -p "$DATA_DIR/hosts";

# Create sites directory
mkdir -p "$SITES_DIR";

if test -n "$LOG_FILE"; then
  # Create log directory
  mkdir -p "$(dirname "$LOG_FILE")";
fi

### Configuration

if test -f '/tmp/nginx-config-template.conf'; then
  # Create configuration file from the configuration template
  envsubst < '/tmp/nginx-config-template.conf' > '/etc/nginx/nginx.conf';
  # Delete the configuration template
  rm '/tmp/nginx-config-template.conf';
fi

if test -f '/tmp/php-fpm-config-template.conf'; then
  # Create PHP-FPM configuration file from the configuration template
  envsubst '${PHP_FPM_SOCKET}' < '/tmp/php-fpm-config-template.conf' > '/etc/nginx/php-fpm.conf';
  # Delete the configuration template
  rm '/tmp/php-fpm-config-template.conf';
fi

if test -f '/tmp/geoip-config-template.conf'; then
  # Create GeoIP configuration file from the configuration template
  envsubst '${GEOIP_COUNTRY_DB} ${GEOIP_CITY_DB}' < '/tmp/geoip-config-template.conf' > '/etc/nginx/geoip.conf';
  # Delete the configuration template
  rm '/tmp/geoip-config-template.conf';
fi

if test -d '/tmp/hosts'; then
  # Delete existing host configuration files
  rm -rf "$DATA_DIR/hosts"/*;
  # Move temporary host configuration files to hosts configuration directory
  mv '/tmp/hosts/'*.conf "$DATA_DIR/hosts/";
  # Delete temporary host configuration files directory
  rm -rf '/tmp/hosts';
fi

if test -d '/tmp/sites'; then
  # Delete existing files in the sites directory
  rm -rf "$SITES_DIR"/*;
  # Move temporary sites files to sites directory
  mv '/tmp/sites/'* "$SITES_DIR/";
  # Delete temporary sites directory
  rm -rf '/tmp/sites';
fi

# Create localhost site directory
mkdir -p "$SITES_DIR/localhost";

# Create localhost public root directory
mkdir -p "$SITES_DIR/localhost/public";

# Create localhost logs directory
# Todo: Consider moving the logs to the /mnt/data/logs directory
mkdir -p "$SITES_DIR/localhost/logs";

# Start cron daemon
crond;

# Start NGINX
exec nginx;