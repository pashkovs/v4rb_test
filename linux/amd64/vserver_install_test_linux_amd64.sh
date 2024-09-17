#!/bin/bash

set -e

# Check if the VERSION parameter is provided
if [ -z "$1" ]; then
    echo "Please provide the VERSION to download as the first parameter."
    exit 1
fi

# Assign the VERSION parameter to a variable
VERSION="$1"
# Extract the major VERSION from the provided VERSION
MAJOR_VERSION=$(echo "$VERSION" | cut -d '.' -f 1)

# Construct the DEB file name
DEB_FILE="vserver_x64_${MAJOR_VERSION}_lin.deb"

# Download the specified VERSION of the V4RB for macOS
curl "https://valentina-db.com/download/prev_releases/$VERSION/lin_64/$DEB_FILE" -o $DEB_FILE

# Install the package
sudo apt install ./$DEB_FILE

VSERVER_LOGS_DIR="/opt/VServer/vlogs"

# The server startup takes some time, so need to try again after delay

attempt=0
max_attempts=5
log_found=false

while [ $attempt -lt $max_attempts ]; do
    # Get the latest log file from the VServer logs directory with name starting with "vserver_" and ending with ".log"
    VSERVER_LOG_FILE=$(ls -t "$VSERVER_LOGS_DIR"/vserver_*.log 2>/dev/null | head -n 1)

    if [ -n "$VSERVER_LOG_FILE" ] && sudo grep -q "Server started" "$VSERVER_LOG_FILE"; then
        log_found=true
        break
    fi

    echo "Log file not found or 'Server started' message not present. Retrying in 5 seconds..."
    sleep 5
    attempt=$((attempt + 1))
done

if [ "$log_found" = false ]; then
    echo "Error: Server did not start successfully after $max_attempts attempts."
    exit 1
fi

# Extract the Valentina Version from the log file using awk
VAL_VERSION=$(sudo awk -F ': ' '/vServer version/{print $2}' "$VSERVER_LOG_FILE" | xargs)

echo "Valentina Version: $VAL_VERSION"
echo "Expected Version: $VERSION"

# Compare the extracted version with the passed parameter
if [ "$VAL_VERSION" != "$VERSION" ]; then
    echo "Error: Valentina Version ($VAL_VERSION) does not match the specified version ($VERSION)."
    exit 1
fi