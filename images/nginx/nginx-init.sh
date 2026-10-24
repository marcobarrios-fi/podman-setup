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

# Start NGINX
exec nginx;