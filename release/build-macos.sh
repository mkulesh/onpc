#!/bin/bash

# The macOS build can be currently done on master channel only
flutter channel master
flutter doctor
flutter build macos --release
mv ../build/macos/Build/Products/Release/Music\ Control.app .

# Use create-dmg in order to create installation image
# https://github.com/create-dmg/create-dmg
# brew install create-dmg

create-dmg \
  --volname "Music Control" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "Application.app" 200 190 \
  --hide-extension "Application.app" \
  --app-drop-link 600 185 \
  "onpc-v2.9.5-release.dmg" \
  "Music Control.app/"

mv rw.onpc-v2.9.5-release.dmg onpc-v2.9.5-release.dmg
rm -rf Music\ Control.app
