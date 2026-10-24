# WordPress Container

WordPress Alpine Linux container using SQLite database for portability and minimal resource usage.

## Files

**WordPress Podman container initialization script**
Used by build scripts to build the Podman container
`wordpress-container-init.sh`

**WordPress Podman container image**
Podman container image
`wordpress.image` 

**WordPress Podman container configuration file**
Configuration file for overwriting build-time arguments
`wordpress-image.conf`

**WordPress PHP FastCGI Process Manager (FPM) configuration file**
PHP-FPM configuration
`wordpress-php-fpm.conf`

**WordPress configuration file**
WordPress configuration
`wp-config.php`

**WordPress initialization script**
Script running every time the container starts
`wordpress-init.sh`