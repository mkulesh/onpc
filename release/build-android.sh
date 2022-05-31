#!/bin/bash

echo Build Android app...

# Prepare Yaml file
rm -f ../pubspec.yaml
ln -s pubspec.yaml_mobile ../pubspec.yaml

# Build with: Flutter version 2.8.1, Dart version 2.15.1
flutter clean
cd /work/android/flutter
git checkout 2.8.1
cd -
flutter doctor -v

# Prepare platform-specific files: disable flutter_libserialport
rm -f ../lib/utils/CompatUtils.dart
ln -s CompatUtils.dart.mobile ../lib/utils/CompatUtils.dart

# Build APK
VER=`cat VERSION.txt`
APP_NAME=MusicControl-v${VER}-android.apk
echo Building $APP_NAME

rm -rf ./$APP_NAME
flutter build apk --release

mv ../build/app/outputs/apk/release/app-release.apk ./$APP_NAME
