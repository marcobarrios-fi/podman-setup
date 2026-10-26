#!/bin/sh

# marcobarrios.fi GeoIP Update Exec Shell Script
# /usr/local/bin/geoipupdate-exec
# Updates MaxMind GeoIP and GeoLite2 databases

# Documentation: https://dev.maxmind.com/geoip/updating-databases/

# Run GeoIP Update
if test -n "$LOG_FILE"; then
  geoipupdate --config-file "$CONFIG_FILE" >> "$LOG_FILE" 2>&1;
else
  geoipupdate --config-file "$CONFIG_FILE";
fi

## Convert geo-IP database filenames to lowercase

if test "$LOWERCASE_FILENAMES" = 'yes'; then 
  echo 'Converting GeoIP database filenames to lowercase';
  # Retrieve GeoIP database files
  for database_file in "$DATA_DIR"/*.mmdb; do
    if test -f "$database_file"; then
      # Convert filename to lowercase
      filename=$(basename "$database_file" | tr '[:upper:]' '[:lower:]');
      if test "$database_file" != "$DATA_DIR/$filename"; then
        # Rename the file (uses a temporary file to support case-insensitive filesystems)
        mv -f "$database_file" "$database_file.tmp" && mv -f "$database_file.tmp" "$DATA_DIR/$filename";
      fi
    fi
  done
fi