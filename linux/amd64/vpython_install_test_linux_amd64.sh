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
DEB_FILE="vpython_x64_${MAJOR_VERSION}_lin.deb"

# Download the specified VERSION of VPython for Linux AMD64
curl "https://valentina-db.com/download/prev_releases/$VERSION/lin_64/$DEB_FILE" -o "$DEB_FILE"

# Install the VPython package
sudo apt install -y "./$DEB_FILE"

VPYTHON_INSTALL_DIR="/opt/VPython"

# Import the extension from the installed package and capture the version output
OUTPUT=$(PYTHONPATH="$VPYTHON_INSTALL_DIR${PYTHONPATH:+:$PYTHONPATH}" python3 common/VPython/pythonProject/main.py)

# Extract the Valentina Version from the output using awk
VAL_VERSION=$(echo "$OUTPUT" | awk -F ': ' '/Valentina Version:/{print $2}' | xargs)

echo "Valentina Version: $VAL_VERSION"
echo "Expected Version: $VERSION"

# Compare the extracted version with the passed parameter
if [ "$VAL_VERSION" != "$VERSION" ]; then
    echo "Error: Valentina Version ($VAL_VERSION) does not match the specified version ($VERSION)."
    exit 1
fi
