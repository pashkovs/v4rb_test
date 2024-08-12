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
DMG_FILE="v4rb_x64_${MAJOR_VERSION}_mac.dmg"

# Download the specified VERSION of the V4RB for macOS
curl "https://valentina-db.com/download/prev_releases/$VERSION/mac_64/$DMG_FILE" -o "$DMG_FILE"

# Mount the downloaded disk image
hdiutil attach "$DMG_FILE"

# Install the V4RB package
sudo installer -pkg "/Volumes/${DMG_FILE}/v4rb.pkg" -target /

V4RB_INSTALL_DIR="/Users/Shared/Paradigma Software/V4RB_${MAJOR_VERSION}"

# ValentinaPlugin.xojo_plugin is just ZIP, so we need to unzip it to a subfolder
unzip "$V4RB_INSTALL_DIR/ValentinaPlugin.xojo_plugin" -d "$V4RB_INSTALL_DIR/ValentinaPlugin"

# Copy the V4RB dylib to the test project
cp "$V4RB_INSTALL_DIR/ValentinaPlugin/ValentinaPlugin.xojo_plugin/Valentina/Build Resources/Mac Universal/v4rb_cocoa_64.dylib" 'mac/TestProjectConsole/TestProjectConsole Libs'

# Run the V4RB application
# Run the V4RB application and capture the output
OUTPUT=$(mac/TestProjectConsole/TestProjectConsole)

# Extract the Valentina Version from the output using awk
VAL_VERSION=$(echo "$OUTPUT" | awk -F ': ' '/Valentina Version:/{print $2}')

# Compare the extracted version with the passed parameter
if [ "$VAL_VERSION" != "$VERSION" ]; then
    echo "Error: Valentina Version ($VAL_VERSION) does not match the specified version ($VERSION)."
    exit 1
fi