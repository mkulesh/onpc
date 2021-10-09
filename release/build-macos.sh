#!/bin/bash

echo Build macOS app...

# Prepare Yaml file
rm -f ../pubspec.yaml
ln -s pubspec.yaml_desktop ../pubspec.yaml

# Build with: Flutter version 2.2.1, Dart version 2.13.1
flutter clean
cd /Volumes/ExtWork/home/family/work/android/flutter
git checkout 2.2.1
cd -
flutter doctor -v

VER=`cat VERSION.txt`
APP_NAME=MusicControl-v${VER}-macos.dmg
echo Building $APP_NAME

# Build app
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
  "${APP_NAME}" \
  "Music Control.app/"

mv rw.${APP_NAME} ${APP_NAME}
rm -rf Music\ Control.app
zip -r ${APP_NAME}.zip ${APP_NAME}
