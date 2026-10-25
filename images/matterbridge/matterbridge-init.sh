#!/bin/sh

# marcobarrios.fi Matterbridge Initialization Shell Script
# /usr/local/bin/matterbridge-init

### Directories
# Mounted volumes are not available at the build time

# Create data directory
mkdir -p "$DATA_DIR";

if test -n "$LOG_FILE"; then
  # Create log directory
  mkdir -p "$(dirname "$LOG_FILE")";
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

if test -f '/tmp/zigbee2mqtt-plugin-config-template.json'; then
  # Create Zigbee2MQTT plugin configuration file from the configuration template
  mkdir -p "$DATA_DIR/.matterbridge";
  envsubst < '/tmp/zigbee2mqtt-plugin-config-template.json' > "$DATA_DIR/.matterbridge/matterbridge-zigbee2mqtt.config.json";
  # Delete configuration template
  rm '/tmp/zigbee2mqtt-plugin-config-template.json';
fi

# Add Zigbee2MQTT plugin to Matterbridge
matterbridge --homedir "$DATA_DIR" --add matterbridge-zigbee2mqtt

# Start Matterbridge
exec matterbridge --homedir "$DATA_DIR" --frontend "$FRONTEND_PORT";