#!/bin/sh

# marcobarrios.fi GeoIP Update Initialization Shell Script
# /usr/local/bin/geoipupdate-init

### Directories
# Mounted volumes are not available at the build time

# Create data directory
mkdir -p "$DATA_DIR";

if test -n "$LOG_FILE"; then
  # Create log directory
  mkdir -p "$(dirname "$LOG_FILE")";
fi

### Secrets

if test -s '/run/secrets/maxmind-account-id'; then
  # Set MaxMind account identifier environment variable
  export MAXMIND_ACCOUNT_ID="$(cat '/run/secrets/maxmind-account-id')";
else 
  echo 'Error: MaxMind account identifier secret is not specified' > '/dev/stderr';
fi

if test -s '/run/secrets/maxmind-license-key'; then
  # Set MaxMind license key environment variable
  export MAXMIND_LICENSE_KEY="$(cat '/run/secrets/maxmind-license-key')";
else
  echo 'Error: MaxMind license key secret is not specified' > '/dev/stderr';
fi

### Configuration

if test -f '/tmp/geoipupdate-config-template.conf'; then
  # Create configuration file from the configuration template
  envsubst < '/tmp/geoipupdate-config-template.conf' > "$CONFIG_FILE";
  # Delete configuration template
  rm '/tmp/geoipupdate-config-template.conf';
fi

# Run GeoIP Update
if test -n "$LOG_FILE"; then
  exec geoipupdate >> "$LOG_FILE" 2>&1;
else
  exec geoipupdate;
fi

## Convert geo-IP database filenames to lowercase

if test "$LOWERCASE_FILENAMES" = 'yes'; then 
  echo 'Converting GeoIP database filenames to lowercase';
  # Retrieve GeoIP database files
  for database_file in "$DATA_DIR"/*.mmdb; do
    if test -f "$database_file"; then
      # Convert filename to lowercase
      filename=$(basename "$database_file" | tr '[:upper:]' '[:lower:]');
      # Rename the file
      mv --force "$database_file" "$DATA_DIR/$filename";
    fi
  done
fi

# Keep the container running indefinitely
exec sleep infinity;