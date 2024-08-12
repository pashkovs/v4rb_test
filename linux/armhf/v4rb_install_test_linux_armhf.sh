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

# Construct the DEB file names
DEB_FILE="v4rb_armhf_32_${MAJOR_VERSION}_lin.deb"
DEB_FILE_64="v4rb_x64_${MAJOR_VERSION}_lin.deb"

# Download the specified VERSION of the V4RB
curl "https://valentina-db.com/download/prev_releases/$VERSION/lin_arm_32/$DEB_FILE" -o linux/armhf/v4rb_armhf_32_lin.deb
curl "https://valentina-db.com/download/prev_releases/$VERSION/lin_64/$DEB_FILE_64" -o $DEB_FILE_64

# Install the V4RB 64-bit package to get V4RB library from it
sudo apt install ./$DEB_FILE_64

V4RB_INSTALL_DIR="/opt/V4RB"

# ValentinaPlugin.xojo_plugin is just ZIP, so we need to unzip it to a subfolder
sudo unzip "$V4RB_INSTALL_DIR/ValentinaPlugin.xojo_plugin" -d "$V4RB_INSTALL_DIR/ValentinaPlugin"

# Copy the V4RB dylib to the test project
cp "$V4RB_INSTALL_DIR/ValentinaPlugin/ValentinaPlugin.xojo_plugin/Valentina/Build Resources/Linux ARM/v4rb_armhf_32_release.so" 'linux/armhf/TestProjectConsole/TestProjectConsole Libs'

# Build the Docker image for the ARM architecture
docker buildx build --platform linux/arm/v7 -t v4rb_armhf_test --load linux/armhf

echo "Running the V4RB application in container..."

# Run the container and capture the output
OUTPUT=$(docker run --rm --platform linux/arm/v7 v4rb_armhf_test $VERSION)

# Extract the Valentina Version from the output using awk
VAL_VERSION=$(echo "$OUTPUT" | awk -F ': ' '/Valentina Version:/{print $2}' | xargs)

echo "Valentina Version: $VAL_VERSION"
echo "Expected Version: $VERSION"

# Compare the extracted version with the passed parameter
if [ "$VAL_VERSION" != "$VERSION" ]; then
    echo "Error: Valentina Version ($VAL_VERSION) does not match the specified version ($VERSION)."
    exit 1
fi


