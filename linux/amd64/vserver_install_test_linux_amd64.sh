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

# Install the V4RB package
sudo apt install ./$DEB_FILE

VSERVER_LOGS_DIR="/opt/VServer/vlogs"

# Get the latest log file from the VServer logs directory with name starting with "vserver_" and ending with ".log"
VSERVER_LOG_FILE=$(ls -t "$VSERVER_LOGS_DIR"/vserver_*.log | head -n 1)

# Extract the Valentina Version from the log file using awk
VAL_VERSION=$(awk -F ': ' '/vServer version/{print $2}' "$VSERVER_LOG_FILE" | xargs)

echo "Valentina Version: $VAL_VERSION"
echo "Expected Version: $VERSION"

# Compare the extracted version with the passed parameter
if [ "$VAL_VERSION" != "$VERSION" ]; then
    echo "Error: Valentina Version ($VAL_VERSION) does not match the specified version ($VERSION)."
    exit 1
fi

# Find Server started message in the log file
if ! grep -q "Server started" "$VSERVER_LOG_FILE"; then
    echo "Error: Server did not start successfully."
    exit 1
fi