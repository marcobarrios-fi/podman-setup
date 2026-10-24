#!/bin/sh

# home.marcobarrios.no Mosquitto Initialization Shell Script
# /usr/local/bin/mosquitto-init

### Directories
# Mounted volumes are not available at the build time

# Create data directory
mkdir -p "$DATA_DIR";

if test -n "$LOG_FILE"; then
  # Create log directory
  mkdir -p "$(dirname "$LOG_FILE")";
  # Create log file
  touch "$LOG_FILE";
fi

### Authentication
# Secrets are not available at the build time

# Export MQTT password as an environment variable
if test -f '/run/secrets/mqtt-password'; then
  export MQTT_PASSWORD=$(cat '/run/secrets/mqtt-password');
fi

# Create password file
mosquitto_passwd -b -c "$PASSWORD_FILE" "$MQTT_USERNAME" "$MQTT_PASSWORD";

# Set password file permissions
chmod 700 "$PASSWORD_FILE";

# Set password file ownership
chown "$USER:$GROUP" "$PASSWORD_FILE";

### Configuration

if test -f '/tmp/mosquitto-config.conf'; then
  # Create configuration file from the configuration template
  envsubst < '/tmp/mosquitto-config.conf' > "$CONFIG_FILE";
  # Delete configuration template
  rm '/tmp/mosquitto-config.conf';
fi

# Start Mosquitto with the specified configuration file
exec mosquitto -c "$CONFIG_FILE";