#!/bin/sh

# Podman Initialization Shell Script

# Enable strict error handling 
# (the script will stop immediately if a variable is not set or a command fails)
set -eu;

# Usage instructions for the script
USAGE_INSTRUCTIONS="Usage: $(tput bold)podman-init <GitHub repository URL> <GitHub repository access token>$(tput sgr0)";

echo "Initializing Podman...";

# The script expects two arguments; the repository URL and the repository access token

# Verify that the GitHub repository URL argument was provided
if test "$#" -lt 1; then
  echo "$(tput bold)$(tput setaf 1)Error: GitHub repository URL argument was not provided.$(tput sgr0)";
  echo "$USAGE_INSTRUCTIONS" && exit 1;
fi

# Verify that the GitHub repository access token argument was provided
if test "$#" -lt 2; then
  echo "$(tput bold)$(tput setaf 1)Error: GitHub repository access token argument was not provided.$(tput sgr0)";
  echo "$USAGE_INSTRUCTIONS" && exit 1;
fi

# GitHub repository URL
GITHUB_REPOSITORY_URL="$1";

# GitHub repository access token
GITHUB_REPOSITORY_TOKEN="$2";

# Verify that the repository URL is specified
if test ! -n "${GITHUB_REPOSITORY_URL:-}"; then
  echo "$(tput bold)$(tput setaf 1)Error: GitHub repository URL is not specified.$(tput sgr0)" && exit 1;
fi

# Verify that the repository access token is specified
if test ! -n "${GITHUB_REPOSITORY_TOKEN:-}"; then
  echo "$(tput bold)$(tput setaf 1)Error: GitHub repository access token is not specified.$(tput sgr0)" && exit 1;
fi

# Create temporary directory
echo "Creating temporary scripts directory...";
TEMP_DIR=$(mktemp --directory);

# Verify that the temporary directory was successfully created
if test ! -d "$TEMP_DIR"; then
  echo "$(tput bold)$(tput setaf 1)Error: Temporary directory could not be created.$(tput sgr0)" && exit 1;
fi

# Display temporary directory
echo "Temporary directory:"
echo "$(tput bold)$(tput setaf 4)$TEMP_DIR$(tput sgr0)";

# Create source directory
SOURCE_DIR="$TEMP_DIR/install";
mkdir -p "$SOURCE_DIR";

# Download source files from the GitHub repository
echo "Downloading source files from the GitHub repository...";
git clone "https://github.com/marcobarrios-fi/podman-setup.git" "$SOURCE_DIR";

echo "$(tput bold)$(tput setaf 2)Downloading source files completed.$(tput sgr0)";

# Create configuration directory
CONFIG_DIR="$TEMP_DIR/config";
mkdir -p "$CONFIG_DIR";

# Download configuration files from the GitHub repository
echo "Downloading configuration files from the GitHub repository...";
git clone "https://x-access-token:$GITHUB_REPOSITORY_TOKEN@github.com/$GITHUB_REPOSITORY_URL.git" "$CONFIG_DIR";

echo "$(tput bold)$(tput setaf 2)Downloading configuration files completed.$(tput sgr0)";

# Link source files to the configuration directory
for image_dir in "$CONFIG_DIR/images/"*/; do
  if test -d "$image_dir"; then
    image_name=$(basename "$image_dir");

    ln -s "$CONFIG_DIR/podman/pods/$image_name" "$image_dir";

    if test -d "$SOURCE_DIR/$image_name"; then
      for file in "$SOURCE_DIR/$image_name/"*; do
        if test -e "$file"; then
          ln -s "$file" "$image_dir";
        fi;
      done
    fi
  fi
done

### Secrets

# Secrets initialization script
SECRETS_INIT_SCRIPT="$SOURCE_DIR/scripts/podman-secrets-init.sh";

# Verify that the secrets initialization script exists
if test ! -f "$SECRETS_INIT_SCRIPT"; then
  echo "$(tput bold)$(tput setaf 1)Error: Secrets initialization script does not exist.$(tput sgr0)" && exit 1;
fi

# Execute secrets initialization script 
# (passes the configuration directory as an environment variable to the script)
env CONFIG_DIR="$CONFIG_DIR" sh "$SECRETS_INIT_SCRIPT";

### Pods

# Pods initialization script
PODS_INIT_SCRIPT="$SOURCE_DIR/scripts/podman-pods-init.sh";

# Verify that the pods initialization script exists
if test ! -f "$PODS_INIT_SCRIPT"; then
  echo "$(tput bold)$(tput setaf 1)Error: Pods initialization script does not exist.$(tput sgr0)" && exit 1;
fi

# Execute pods initialization script 
# (passes the configuration directory as an environment variable to the script)
env CONFIG_DIR="$CONFIG_DIR" sh "$PODS_INIT_SCRIPT";

### Cleanup

# Delete temporary directory
echo "Deleting temporary directory...";
rm -rf "$TEMP_DIR";

# Remove unused Podman images
echo 'Removing unused Podman images...';
podman image prune --all --force;

# List Podman images
echo "Podman container images:";
echo "$(tput dim)" && podman images && echo "$(tput sgr0)";

echo "$(tput bold)$(tput setaf 2)Podman initialization completed.$(tput sgr0)";