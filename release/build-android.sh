#!/bin/bash

# Set this parameter to the actual Flutter installation path
# Call "git fetch" in this directory so that your local Flutter
# repository gets all the new info from Github

# For gradle-7.5, currently used in the project, Java 17 shall be used:
# Setup it with the command:
# flutter config  --jdk-dir /work/android/gradle-java17
FLUTTER_PATH=/work/android/flutter

echo Build Android app...

# Prepare Yaml file
rm -f ../pubspec.yaml
ln -s pubspec.yaml_mobile ../pubspec.yaml

# Build with: Flutter version 3.19.0, Dart version 3.3.0
flutter clean
cd ${FLUTTER_PATH}
git checkout 3.19.0
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
