#!/bin/sh

# marcobarrios.fi Geoipupdate Run Shell Script
# /usr/local/bin/geoipupdate-run
# Updates MaxMind geo-IP databases

# Set account ID environment variable
# (Podman secrets are available on the container on the /run/secrets directory)
if [ -s '/run/secrets/maxmind-account-id' ]; then
  export GEOIPUPDATE_ACCOUNT_ID_FILE='/run/secrets/maxmind-account-id';
else 
  echo 'Error: MaxMind accound ID secret is unspecified' > '/dev/stderr' && exit 1;
fi

# Set license key environment variable
# (Podman secrets are available on the container on the /run/secrets directory)
if [ -s '/run/secrets/maxmind-license-key' ]; then
  export GEOIPUPDATE_LICENSE_KEY_FILE='/run/secrets/maxmind-license-key';
else 
  echo 'Error: MaxMind license key secret is unspecified' > '/dev/stderr' && exit 1;
fi

# Verify geo-IP database directory
if [ ! -d "$GEOIP_DB_DIR" ]; then
  echo 'Error: Geo-IP database directory is unspecified or does not exist' > '/dev/stderr' && exit 1;
fi

# Update MaxMind geo-IP databases
geoipupdate;

## Convert geo-IP database filenames to lowercase
if [ "$GEOIPUPDATE_LOWERCASE_FILENAMES" = 'yes' ]; then 
   echo 'Converting geo-IP database filenames to lowercase';
  # Repeat for each geo-IP database file
  for file in "$GEOIP_DB_DIR"/*.mmdb; do
    if [ -f "$file" ]; then
      # Convert filename to lowercase
      lowercase_filename=$(basename "$file" | tr '[:upper:]' '[:lower:]');
      mv --force "$file" "$GEOIP_DB_DIR/$lowercase_filename";
    fi
  done
fi