#!/bin/sh

# marcobarrios.fi Zigbee2MQTT Initialization Shell Script
# /usr/local/bin/zigbee2mqtt-init

### Directories
# Mounted volumes are not available at the build time

# Create data directory
mkdir -p "$DATA_DIR";

# Create log directory
if test -n "$LOG_FILE"; then
  mkdir -p "$(dirname "$LOG_FILE")";
fi

### Secrets
# Secrets are not available at the build time

# Export MQTT password as an environment variable
if test -s '/run/secrets/mqtt-password'; then
  export MQTT_PASSWORD=$(cat '/run/secrets/mqtt-password');
else
  echo 'Error: MQTT password secret is not specified' > '/dev/stderr';
fi

### Configuration

if test -f '/tmp/config-template.yaml'; then
  # Create configuration file from the configuration template
  envsubst < '/tmp/config-template.yaml' > "$CONFIG_FILE";
  # Delete configuration template
  rm '/tmp/config-template.yaml';
fi

# Start Zigbee2MQTT
if test -n "$LOG_FILE"; then
  exec zigbee2mqtt --config "$CONFIG_FILE" --log-level 'info' --log-file "$LOG_FILE";
else
  exec zigbee2mqtt --config "$CONFIG_FILE" --log-level 'info';
fi