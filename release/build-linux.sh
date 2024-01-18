#!/bin/bash

# Set this parameter to the actual Flutter installation path
FLUTTER_PATH=/work/android/flutter

echo Build Linux app...

# Necessary Fedora packages:
# dnf install clang cmake ninja-build gtk3-devel xz-devel

# Prepare Yaml file
rm -f ../pubspec.yaml
ln -s pubspec.yaml_desktop ../pubspec.yaml

# Build with: Flutter version 3.16.0, Dart version 3.2.0
flutter clean
cd ${FLUTTER_PATH}
git checkout 3.16.0
cd -
flutter doctor -v

# Prepare platform-specific files: enable flutter_libserialport
rm -f ../lib/utils/CompatUtils.dart
ln -s CompatUtils.dart.desktop ../lib/utils/CompatUtils.dart

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
