#!/bin/bash

# Set this parameter to the actual Flutter installation path
FLUTTER_PATH=/Volumes/work/android/flutter

echo Build iOS app...

# Prepare Yaml file
rm -f ../pubspec.yaml
ln -s pubspec.yaml_mobile ../pubspec.yaml

# Build with: Flutter version 3.16.0, Dart version 3.2.0
flutter clean
cd ${FLUTTER_PATH}
git checkout 3.16.0
cd -
flutter doctor -v

# Prepare platform-specific files: disable flutter_libserialport
rm -f ../lib/utils/CompatUtils.dart
ln -s CompatUtils.dart.mobile ../lib/utils/CompatUtils.dart

# Build app
flutter build ios --release
