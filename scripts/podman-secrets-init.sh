#!/bin/sh

# Podman Secrets Initialization Shell Script
# Creates Podman secrets based on Kubernetes YAML files
# Usage: env CONFIG_DIR="<configuration_directory>" sh podman-secrets-init.sh

# Enable strict error handling 
# (the script will stop immediately if a variable is not set or a command fails)
set -eu;

# Prompt initializing secrets
printf "$(tput bold)Initialize secrets? (Yes/No) $(tput sgr0)" && read input;

# Evaluate user input for initializing secrets
if test "$input" = "YES" || test "$input" = "Yes" || test "$input" = "yes" || test "$input" = "Y" || test "$input" = "y"; then

  # Verify that the configuration directory environment variable is specified
  if test ! -n "${CONFIG_DIR:-}"; then
    echo "$(tput bold)$(tput setaf 1)Error: Configuration directory is not specified.$(tput sgr0)" && exit 1;
  fi

  # Verify that the configuration directory exists
  if test ! -d "$CONFIG_DIR"; then
    echo "$(tput bold)$(tput setaf 1)Error: Configuration directory does not exist.$(tput sgr0)" && exit 1;
  fi

  SECRETS_DIR="$CONFIG_DIR/podman/secrets";

  echo "Secrets directory:" && echo '/podman/secrets';

  # Verify that the secrets directory exists
  if test ! -d "$SECRETS_DIR"; then
    echo "$(tput bold)$(tput setaf 1)Error: Secrets configuration directory does not exist.$(tput sgr0)" && exit 1;
  fi

  # Assign secrets as positional arguments
  set -- "$SECRETS_DIR/"*.yaml;

  # If secrets are specified
  if test -e "$1"; then

    for SECRET in "$@"; do

      SECRET_NAME=$(basename "$SECRET" '.yaml');

      # If the secret does not exist
      if ! podman secret exists "$SECRET_NAME"; then
          
          # Prompt secret value
          printf "$(tput bold)Enter secret for $SECRET_NAME: $(tput sgr0)" && read SECRET_VALUE;
          
          # Set secret environment variable
          export SECRET_VALUE;
          
          # Set secret
          podman secret create --env=true "$SECRET_NAME" 'SECRET_VALUE';

          # Unset secret environment variable
          unset SECRET_VALUE;
          
      fi

      # Display secret details
      echo "$SECRET_NAME secret:";
      echo "$(tput dim)"; 
      podman secret inspect --pretty "$SECRET_NAME";
      echo "$(tput sgr0)";

    done

  else 

    echo "$(tput bold)$(tput setaf 3)Warning: No secret configuration files found.$(tput sgr0)";

  fi

  echo "$(tput bold)$(tput setaf 2)Secrets initialization completed.$(tput sgr0)";

else

  echo "$(tput bold)Secrets initialization canceled.$(tput sgr0)";

fi