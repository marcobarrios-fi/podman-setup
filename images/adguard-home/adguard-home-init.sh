#!/bin/sh

# marcobarrios.fi AdGuard Home Initialization Shell Script
# /usr/local/bin/adguard-home-init

# Data in the application directory will be deleted every time the container is built

### Directories
# Mounted volumes are not available at the build time

# Create application directory
mkdir -p "$APP_DIR";

# Create data directory
mkdir -p "$DATA_DIR";

# Create filters directory
mkdir -p "$DATA_DIR/filters";

if test -n "$LOG_FILE"; then
  # Create log directory
  mkdir -p "$(dirname "$LOG_FILE")";
fi

### Configuration

if test -f '/tmp/adguard-home-config.yaml'; then
  # Move configuration file to the configuration file location
  mv '/tmp/adguard-home-config.yaml' "$CONFIG_FILE";
fi

if test -d '/tmp/filters'; then
  # Delete existing filter files
  rm -rf "$DATA_DIR/filters"/*;
  # Move temporary filter files to filters directory
  mv '/tmp/filters/'* "$DATA_DIR/filters/";
  # Delete temporary filters directory
  rm -rf '/tmp/filters';
fi

# Run AdGuard Home
if test -n "$LOG_FILE"; then
  exec "$APP" --config "$CONFIG_FILE" --work-dir "$APP_DIR" --logfile "$LOG_FILE";
else
  exec "$APP" --config "$CONFIG_FILE" --work-dir "$APP_DIR";
fi