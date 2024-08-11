#!/bin/bash

# Download the latest version of the V4RB for macOS
curl https://valentina-db.com/download/release/mac_64/v4rb_x64_14_mac.dmg -o v4rb_x64_14_mac.dmg

# Mount the downloaded disk image
hdiutil attach v4rb_x64_14_mac.dmg

# Install the V4RB package
sudo installer -pkg /Volumes/v4rb_x64_14_mac.dmg/v4rb.pkg -target /
