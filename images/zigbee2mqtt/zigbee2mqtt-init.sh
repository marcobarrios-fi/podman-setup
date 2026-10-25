#!/bin/sh

# marcobarrios.fi Zigbee2MQTT Initialization Shell Script
# /usr/local/bin/zigbee2mqtt-init

### Directories
# Mounted volumes are not available at the build time

# Create data directory
mkdir -p "$DATA_DIR";

if test -n "$LOG_FILE"; then
  # Set log directory environment variable
  export LOG_DIR="$(dirname "$LOG_FILE")";
  # Set log file environment variable
  export LOG_FILE="$(basename "$LOG_FILE")";
  # Create log directory
  mkdir -p "$LOG_DIR";
fi

### Secrets
# Secrets are not available at the build time

if test -s '/run/secrets/mqtt-password'; then
  # Set MQTT password environment variable
  export MQTT_PASSWORD=$(cat '/run/secrets/mqtt-password');
else
  echo 'Warning: MQTT password secret is not specified' > '/dev/stderr';
fi

### Configuration

if test -f '/tmp/zigbee2mqtt-config-template.yaml'; then
  # Create configuration file from the configuration template
  envsubst < '/tmp/zigbee2mqtt-config-template.yaml' > "$DATA_DIR/configuration.yaml";
  # Delete configuration template
  rm '/tmp/zigbee2mqtt-config-template.yaml';
fi

# Set Zigbee2MQTT data directory environment variable (used by Zigbee2MQTT to locate its data directory)
export ZIGBEE2MQTT_DATA="$DATA_DIR";

# Start Zigbee2MQTT
exec zigbee2mqtt;