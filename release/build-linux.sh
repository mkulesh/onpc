#!/bin/bash

# Fedora packages:
# dnf install clang cmake ninja-build gtk3-devel xz-devel

VER=`cat VERSION.txt`
APP_NAME=MusicControl-v${VER}-linux-x86_64
echo Building $APP_NAME

rm -rf ./$APP_NAME
rm -rf ${APP_NAME}.zip

# Build with Flutter version 2.0.4, Dart version 2.12.2
cd /work/android/flutter
git checkout 2.0.4
cd -
flutter clean
flutter doctor
flutter build linux --release

mv ../build/linux/release/bundle ./$APP_NAME
cp ./$APP_NAME/data/flutter_assets/lib/assets/app_icon.png ./$APP_NAME/Music-Control.png
zip -r ${APP_NAME}.zip ./$APP_NAME
