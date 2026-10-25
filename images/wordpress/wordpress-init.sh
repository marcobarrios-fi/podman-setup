#!/bin/sh

# marcobarrios.fi WordPress Initialization Shell Script
# /usr/local/bin/wordpress-init

### Directories
# Mounted volumes are not available at the build time

# Create application directory
mkdir -p "$APP_DIR";

# Create data directory
mkdir -p "$DATA_DIR";

if test -n "$LOG_FILE"; then
  # Set log directory environment variable
  export LOG_DIR="$(dirname "$LOG_FILE")";
  # Create the log directory
  mkdir -p "$LOG_DIR";
  # Create access log (used by the Nginx web server)
  touch "$LOG_DIR/access.log";
  # Create error log (used by the NGINX web server)
  touch "$LOG_DIR/error.log";
fi;

# Create uploads directory
mkdir -p "$DATA_DIR/uploads";

### Files

# Create application database file
touch "$DATA_DIR/$DB_FILE";

### Permissions

# Set ownership for the data directory
chown -R "$USER":"$GROUP" "$DATA_DIR";

# Set group write permissions on the data directory
chmod -R g+w "$DATA_DIR";

### Configuration

if test -f '/tmp/php-fpm-config-template.conf'; then
  # Create PHP-FPM configuration file from the configuration template
  envsubst < '/tmp/php-fpm-config-template.conf' > '/etc/php/php-fpm.d/php-fpm.conf';
  # Remove the configuration template
  rm '/tmp/php-fpm-config-template.conf';
fi

if test -d '/tmp/wordpress'; then

  # Delete existing files, including hidden files, from the application directory
  rm -rf "$APP_DIR"/* && find "$APP_DIR" -type f -delete;

  # Move files in the temporary directory to the application directory
  mv '/tmp/wordpress/'* "$APP_DIR/";

  # Delete the temporary directory
  rm -rf '/tmp/wordpress';

  if test -f '/tmp/wordpress-config-template.php'; then
    # Create configuration file from the configuration template
    envsubst '${USER} ${GROUP} ${DATA_DIR} ${DB_FILE}' < '/tmp/wordpress-config-template.php' > "$APP_DIR/wp-config.php";
    # Remove the configuration template
    rm '/tmp/wordpress-config-template.php';
  fi

  # Plugins, themes, and uploads are stored in the data directory

  ## Plugins
  
  if test -d "$APP_DIR/wp-content/plugins"; then
    if test ! -d "$DATA_DIR/plugins"; then
      # Copy existing plugins to the data directory
      cp -r "$APP_DIR/wp-content/plugins" "$DATA_DIR/plugins";
    fi
    # Delete plugins directory
    rm -rf "$APP_DIR/wp-content/plugins";
    # Create symbolic link for plugins pointing to the data directory
    ln -s "$DATA_DIR/plugins" "$APP_DIR/wp-content/plugins";
  fi
  
  ## Themes

  if test -d "$APP_DIR/wp-content/themes"; then
    if test ! -d "$DATA_DIR/themes"; then
      # Copy existing themes to the data directory
      cp -r "$APP_DIR/wp-content/themes" "$DATA_DIR/themes";
    fi
    # Delete themes directory
    rm -rf "$APP_DIR/wp-content/themes";
    # Create symbolic link for themes pointing to the data directory
    ln -s "$DATA_DIR/themes" "$APP_DIR/wp-content/themes";
  fi
  
  if test -d "$APP_DIR/wp-content/uploads"; then
    # Delete uploads directory
    rm -rf "$APP_DIR/wp-content/uploads";
  fi
  
  # Create symbolic link for the uploads directory pointing to the data directory
  ln -s "$DATA_DIR/uploads" "$APP_DIR/wp-content/uploads";

  # Set ownership for the application directory
  chown -R "$USER":"$GROUP" "$APP_DIR";

  # Set group write permissions on the application directory
  chmod -R g+w "$APP_DIR";

fi

# Show WordPress command-line utility information
# exec wp --info;

# Start PHP-FPM
exec php-fpm --nodaemonize;