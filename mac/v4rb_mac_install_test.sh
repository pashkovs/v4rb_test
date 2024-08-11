#!/bin/bash

set -e

# Download the latest version of the V4RB for macOS
curl https://valentina-db.com/download/prev_releases/14.1.1/mac_64/ -o v4rb_x64_14_mac.dmg

# Mount the downloaded disk image
hdiutil attach v4rb_x64_14_mac.dmg

# Install the V4RB package
sudo installer -pkg /Volumes/v4rb_x64_14_mac.dmg/v4rb.pkg -target /

V4RB_INSTALL_DIR='/Users/Shared/Paradigma Software/V4RB_14'

# ValentinaPlugin.xojo_plugin is just ZIP, so we need to unzip it to a subfolder
unzip "$V4RB_INSTALL_DIR/ValentinaPlugin.xojo_plugin" -d "$V4RB_INSTALL_DIR/ValentinaPlugin"

# Copy the V4RB dylib to the test project
cp "$V4RB_INSTALL_DIR/ValentinaPlugin/ValentinaPlugin.xojo_plugin/Valentina/Build Resources/Mac Universal/v4rb_cocoa_64.dylib" 'mac/TestProjectConsole/TestProjectConsole Libs'

# Run the V4RB application
mac/TestProjectConsole/TestProjectConsole