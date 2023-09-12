#!/bin/bash

echo Build Android app...

# Prepare Yaml file
rm -f ../pubspec.yaml
ln -s pubspec.yaml_mobile ../pubspec.yaml

# Build with: Flutter version 3.7.10, Dart version 2.19.6
flutter clean
cd /work/android/flutter
git checkout 3.7.10
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
