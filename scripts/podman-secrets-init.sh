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

  # Verify that the secrets directory exists
  if test ! -d "$SECRETS_DIR"; then
    echo "$(tput bold)$(tput setaf 1)Error: Secrets configuration directory does not exist.$(tput sgr0)" && exit 1;
  fi

  # Assign secrets as positional arguments
  set -- "$SECRETS_DIR/"*.yaml;

  # If secrets are specified
  if test -e "$1"; then

    for SECRET_CONFIG_FILE in "$@"; do

      SECRET_NAME=$(basename "$SECRET_CONFIG_FILE" '.yaml');

      # If the secret does not exist
      if ! podman secret exists "$SECRET_NAME"; then
          
        # Prompt secret value
        printf "$(tput bold)Enter secret for $SECRET_NAME: $(tput sgr0)" && read SECRET;

        # Encode the secret value (Kubernetes secret data is base64 encoded)
        export SECRET="$(printf '%s' "$SECRET" | base64 | tr -d '\n')";

        # Create a temporary configuration file
        TEMP_CONFIG_FILE=$(mktemp);

        # Substitute the secret value in the configuration file template
        envsubst < "$SECRET_CONFIG_FILE" > "$TEMP_CONFIG_FILE";

        # Unset secret environment variable
        unset SECRET;

        # Create secret
        podman kube play --replace --network 'podman' "$TEMP_CONFIG_FILE";

        # Remove the temporary configuration file
        rm -f "$TEMP_CONFIG_FILE";

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