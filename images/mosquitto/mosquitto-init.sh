#!/bin/sh

# marcobarrios.fi Mosquitto Initialization Shell Script
# /usr/local/bin/mosquitto-init

### Directories
# Mounted volumes are not available at the build time

# Create data directory
mkdir -p "$DATA_DIR";

# Set data directory ownership
chown "$USER:$GROUP" "$DATA_DIR";

if test -n "$LOG_FILE"; then
  # Create log directory
  mkdir -p "$(dirname "$LOG_FILE")";
  # Create log file
  touch "$LOG_FILE";
  # Set log file ownership
  chown "$USER:$GROUP" "$LOG_FILE";
fi

### Secrets
# Secrets are not available at the build time.

if test -s '/run/secrets/mqtt-password'; then
  # Set MQTT password environment variable
  export MQTT_PASSWORD=$(cat '/run/secrets/mqtt-password');
else
  echo 'Warning: MQTT password secret is not specified' > '/dev/stderr';
fi

# Create password file
mosquitto_passwd -b -c "$PASSWORD_FILE" "$MQTT_USERNAME" "$MQTT_PASSWORD";

# Set password file ownership
chown "$USER:$GROUP" "$PASSWORD_FILE";

# Set password file permissions
chmod 700 "$PASSWORD_FILE";

### Configuration

if test -f '/tmp/mosquitto-config-template.conf'; then
  # Create configuration file from the configuration template
  envsubst < '/tmp/mosquitto-config-template.conf' > "$CONFIG_FILE";
  # Delete configuration template
  rm '/tmp/mosquitto-config-template.conf';
fi

# Start Mosquitto with the specified configuration file
exec mosquitto -c "$CONFIG_FILE";