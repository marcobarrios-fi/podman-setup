#!/bin/sh

# marcobarrios.fi Homebridge Initialization Shell Script
# /usr/local/bin/homebridge-init

### Directories
# Mounted volumes are not available at the build time

# Create data directory
mkdir -p "$DATA_DIR";

# Create log directory
mkdir -p "$(dirname "$LOG_FILE")";

# Create log file
touch "$LOG_FILE";

### Secrets
# Secrets are not available at the build time.

if test -s '/run/secrets/mqtt-password'; then
  # Set MQTT password environment variable
  export MQTT_PASSWORD=$(cat '/run/secrets/mqtt-password');
else
  echo 'Error: MQTT password secret is not specified' > '/dev/stderr';
fi

### Configuration

if test -f '/tmp/config-template.json'; then
  # Create configuration file from the configuration template
  envsubst < '/tmp/config-template.json' > "$DATA_DIR/config.json";
  # Delete configuration template
  rm '/tmp/config-template.json';
fi 

# Start Homebridge and Homebridge Config UI X
# homebridge --insecure --user-storage-path "$DATA_DIR" --plugin-path "$DATA_DIR/plugins" & node "$UI_BIN" --insecure --user-storage-path "$DATA_DIR";

# Start Homebridge Config UI X
exec node "$UI_BIN" --insecure --user-storage-path "$DATA_DIR";