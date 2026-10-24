#!/bin/sh

# marcobarrios.fi Matterbridge Initialization Shell Script
# /usr/local/bin/matterbridge-init

### Directories
# Mounted volumes are not available at the build time

# Create application directory
mkdir -p "$DATA_DIR";

# Create log directory
mkdir -p "$(dirname "$LOG_FILE")";

### Authentication
# Secrets are not available at the build time

# Export MQTT password as an environment variable
  if test -f '/run/secrets/mqtt-password'; then
  export MQTT_PASSWORD=$(cat '/run/secrets/mqtt-password');
fi

### Configuration

if test -f '/tmp/zigbee2mqtt-plugin-config.json'; then
  # Create Zigbee2MQTT plugin configuration file from the configuration template
  mkdir -p "$DATA_DIR/.matterbridge";
  envsubst < '/tmp/zigbee2mqtt-plugin-config.json' > "$DATA_DIR/.matterbridge/matterbridge-zigbee2mqtt.config.json";
  # Delete configuration template
  rm '/tmp/zigbee2mqtt-plugin-config.json';
fi

# Start Matterbridge
exec matterbridge --homedir "$DATA_DIR" --frontend "$FRONTEND_PORT";