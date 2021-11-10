#!/bin/bash

echo Build Linux app...

# Necessary Fedora packages:
# dnf install clang cmake ninja-build gtk3-devel xz-devel

# Prepare Yaml file
rm -f ../pubspec.yaml
ln -s pubspec.yaml_desktop ../pubspec.yaml

# Build with: Flutter version 2.2.1, Dart version 2.13.1
flutter clean
cd /work/android/flutter
git checkout 2.2.1
cd -
flutter doctor -v

# Prepare platform-specific files: enable flutter_libserialport
rm -f ../lib/utils/UsbSerial.dart
ln -s UsbSerial.dart.desktop ../lib/utils/UsbSerial.dart

# Build app
VER=`cat VERSION.txt`
APP_NAME=MusicControl-v${VER}-linux-x86_64
echo Building $APP_NAME

rm -rf ./$APP_NAME
rm -rf ${APP_NAME}.zip
flutter build linux --release

mv ../build/linux/x64/release/bundle ./$APP_NAME
cp ./$APP_NAME/data/flutter_assets/lib/assets/app_icon.png ./$APP_NAME/Music-Control.png
zip -r ${APP_NAME}.zip ./$APP_NAME
