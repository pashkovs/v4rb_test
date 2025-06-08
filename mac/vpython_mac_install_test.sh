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

# Preprocess the VERSION to construct the DMG file name
DMG_FILE="vpython_x64_${MAJOR_VERSION}_mac.dmg"

# Download the specified VERSION of the VPython for macOS
curl "https://valentina-db.com/download/prev_releases/$VERSION/mac_64/$DMG_FILE" -o "$DMG_FILE"

# Mount the downloaded disk image
hdiutil attach "$DMG_FILE"

# Install the V4RB package
sudo installer -pkg "/Volumes/${DMG_FILE}/vpython.pkg" -target /

VPYTHON_INSTALL_DIR="/Users/Shared/Paradigma Software/VPython_x64_${MAJOR_VERSION}"

# Copy the valentina.so to the test project
cp "$VPYTHON_INSTALL_DIR/valentina.so" 'common/VPython/pythonProject'

# Run the V4RB application and capture the output
OUTPUT=$(python3 common/VPython/pythonProject/main.py)

# Extract the Valentina Version from the output using awk
VAL_VERSION=$(echo "$OUTPUT" | awk -F ': ' '/Valentina Version:/{print $2}' | xargs)

echo "Valentina Version: $VAL_VERSION"
echo "Expected Version: $VERSION"

# Compare the extracted version with the passed parameter
if [ "$VAL_VERSION" != "$VERSION" ]; then
    echo "Error: Valentina Version ($VAL_VERSION) does not match the specified version ($VERSION)."
    exit 1
fi