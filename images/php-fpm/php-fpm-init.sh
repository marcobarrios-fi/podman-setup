#!/bin/sh

# marcobarrios.fi PHP-FPM Initialization Shell Script
# /usr/local/bin/php-fpm-init

### Directories
# Mounted volumes are not available at the build time

# Create data directory
mkdir -p "$DATA_DIR";

if test -n "$LOG_FILE"; then
  # Create log directory
  mkdir -p "$(dirname "$LOG_FILE")";
fi

# Start PHP-FPM
exec php-fpm --nodaemonize