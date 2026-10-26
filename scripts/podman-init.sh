#!/bin/sh

# Podman Initialization Shell Script
# Usage: podman machine ssh <podman machine name> && curl --location --output 'podman-init.sh' 'https://barrios.co/podman-init' && sh 'podman-init.sh' '<GitHub repository name>' '<GitHub repository access token>'

# Enable strict error handling 
# (the script will stop immediately if a variable is not set or a command fails)
set -eu;

# Usage instructions for the script
USAGE_INSTRUCTIONS="Usage: $(tput bold)podman-init <GitHub repository name> <GitHub repository access token>$(tput sgr0)";

echo "Initializing Podman...";

# The script expects two arguments; the repository name and the repository access token
# During first execution, the script will save the repository name and access token as environment variables
# Subsequent executions will use the saved environment variable values

if test -n "${1:-}" && test -n "${2:-}"; then
  
  echo "# Podman Initialization Environment Variables" > '/etc/profile.d/podman-init.sh';

  # GitHub repository name
  GITHUB_REPOSITORY_NAME="$1";
  echo "export GITHUB_REPOSITORY_NAME=$GITHUB_REPOSITORY_NAME" >> '/etc/profile.d/podman-init.sh';

  # GitHub repository access token
  GITHUB_REPOSITORY_TOKEN="$2";
  echo "export GITHUB_REPOSITORY_TOKEN=$GITHUB_REPOSITORY_TOKEN" >> '/etc/profile.d/podman-init.sh';

fi

# Verify that the repository name is specified
if test -z "${GITHUB_REPOSITORY_NAME:-}"; then
  echo "$(tput bold)$(tput setaf 1)Error: GitHub repository name is not specified.$(tput sgr0)" && echo "$USAGE_INSTRUCTIONS" && exit 1;
fi

# Verify that the repository access token is specified
if test -z "${GITHUB_REPOSITORY_TOKEN:-}"; then
  echo "$(tput bold)$(tput setaf 1)Error: GitHub repository access token is not specified.$(tput sgr0)" && echo "$USAGE_INSTRUCTIONS" && exit 1;
fi

# Create temporary directory
echo "Creating temporary scripts directory...";
TEMP_DIR=$(mktemp --directory);

### Cleanup

cleanup() {
  
  # Delete temporary directory
  echo "Deleting temporary directory...";
  rm -rf "$TEMP_DIR";

  # Remove unused Podman images
  echo 'Removing unused Podman images...';
  podman image prune --all --force;

}

# Execute cleanup on script exit, hangup, interrupt, or termination signals
trap cleanup EXIT HUP INT TERM;

# Verify that the temporary directory was successfully created
if test ! -d "$TEMP_DIR"; then
  echo "$(tput bold)$(tput setaf 1)Error: Temporary directory could not be created.$(tput sgr0)" && exit 1;
fi

# Display temporary directory
echo "Temporary directory:";
echo "$(tput bold)$(tput setaf 4)$TEMP_DIR$(tput sgr0)";

# Create source directory
SOURCE_DIR="$TEMP_DIR/install";
mkdir -p "$SOURCE_DIR";

# Download source files from the GitHub repository
echo "Downloading source files from the GitHub repository...";
echo "$(tput dim)";
git clone "https://github.com/marcobarrios-fi/podman-setup.git" "$SOURCE_DIR";
echo "$(tput sgr0)";

echo "$(tput bold)$(tput setaf 2)Downloading source files completed.$(tput sgr0)";

# Create configuration directory
CONFIG_DIR="$TEMP_DIR/config";
mkdir -p "$CONFIG_DIR";

# Download configuration files from the GitHub repository
echo "Downloading configuration files from the GitHub repository...";
echo "$(tput dim)";
git clone "https://x-access-token:$GITHUB_REPOSITORY_TOKEN@github.com/$GITHUB_REPOSITORY_NAME.git" "$CONFIG_DIR";
echo "$(tput sgr0)";

echo "$(tput bold)$(tput setaf 2)Downloading configuration files completed.$(tput sgr0)";

# Copy image source files to the configuration directory
# (Podman builds a local image from a directory named after the image)

for IMAGE_DIR in "$SOURCE_DIR/images/"*/; do
  
  if test -d "$IMAGE_DIR"; then
    
    # Image name (derived from the directory name)
    IMAGE_NAME=$(basename "$IMAGE_DIR");

    # Create the image directory in the configuration directory if it does not exist
    mkdir -p "$CONFIG_DIR/$IMAGE_NAME";

    # Copy all files and directories from the source image directory to the configuration directory
    cp -R "$IMAGE_DIR"* "$CONFIG_DIR/$IMAGE_NAME/";

  fi

done

### Secrets
# Secrets are not available at the build time

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

trap - EXIT HUP INT TERM;

cleanup;

# List Podman images
echo "Podman container images:";
echo "$(tput dim)" && podman images && echo "$(tput sgr0)";

echo "$(tput bold)$(tput setaf 2)Podman initialization completed.$(tput sgr0)";