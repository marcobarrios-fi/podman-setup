#!/bin/sh

# Podman Pods Initialization Shell Script
# Creates Podman containers, pods, and volumes based on Kubernetes YAML files
# Usage: env CONFIG_DIR="<configuration_directory>" sh podman-pods-init.sh

# Enable strict error handling 
# (the script will stop immediately if a variable is not set or a command fails)
set -eu;

# Prompt initializing pods
printf "$(tput bold)Initialize pods? (Yes/No) $(tput sgr0)" && read input;

# Evaluate user input for initializing pods
if test "$input" = "YES" || test "$input" = "Yes" || test "$input" = "yes" || test "$input" = "Y" || test "$input" = "y"; then

  # Verify that the configuration directory environment variable is specified
  if test ! -n "${CONFIG_DIR:-}"; then
    echo "$(tput bold)$(tput setaf 1)Error: Configuration directory is not specified.$(tput sgr0)" && exit 1;
  fi

  # Verify that the configuration directory exists
  if test ! -d "$CONFIG_DIR"; then
    echo "$(tput bold)$(tput setaf 1)Error: Configuration directory does not exist.$(tput sgr0)" && exit 1;
  fi

  PODS_DIR="$CONFIG_DIR/podman/pods";

  echo "Pods directory: $PODS_DIR";

  # Verify that the pods directory exists
  if test ! -d "$PODS_DIR"; then
    echo "$(tput bold)$(tput setaf 1)Error: Pods configuration directory does not exist.$(tput sgr0)" && exit 1;
  fi

  # Assign pods as positional arguments
  set -- "$PODS_DIR/"*.yaml;

  # If pods are specified
  if test -e "$1"; then

    for POD in "$@"; do

      POD_NAME=$(basename "$POD" '.yaml');

      # Prompt initializing the pod
      printf "$(tput bold)Initialize pod $POD_NAME? (Yes/No) $(tput sgr0)" && read input;

      # Evaluate user input for initializing the pod
      if test "$input" = "YES" || test "$input" = "Yes" || test "$input" = "yes" || test "$input" = "Y" || test "$input" = "y"; then
          
        # Create pod
        podman kube play --replace --no-pod-prefix "$PODS_DIR/$POD";

        # Display pod details
        echo "$POD_NAME pod:";
        echo "$(tput dim)" && podman pod inspect "$POD_NAME" && echo "$(tput sgr0)";

      fi

    done

  else

    echo "$(tput bold)$(tput setaf 3)Warning: No pod configuration files found.$(tput sgr0)";

  fi

else

  echo "$(tput bold)$(tput setaf 3)Warning: Pods initialization skipped.$(tput sgr0)";

fi