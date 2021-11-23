#!/bin/bash

echo Build iOS app...

# Prepare Yaml file
rm -f ../pubspec.yaml
ln -s pubspec.yaml_ios ../pubspec.yaml

# Build with: Flutter version 1.22.6, Dart version 2.10.5
flutter clean
cd /Volumes/ExtWork/home/family/work/android/flutter
git checkout 1.22.6
cd -
flutter doctor -v

# Prepare platform-specific files: disable flutter_libserialport
rm -f ../lib/utils/CompatUtils.dart
ln -s CompatUtils.dart.mobile ../lib/utils/CompatUtils.dart

# Build app
flutter build ios --release
