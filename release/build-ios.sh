#!/bin/bash

# Note: The Impeller for Flutter 3.16.0 results in really bad
# rendering quality for the flutter_svg library. It is temporary
# disabled in the file ios/Runner/Info.plist, parameter FLTEnableImpeller
# When rendering quality will be fixed in any later Flutter version,
# the Impeller can be enabled again by deleting this parameter.

# Set this parameter to the actual Flutter installation path
# Call "git fetch" in this directory so that your local Flutter
# repository gets all the new info from Github
FLUTTER_PATH=/Volumes/work/android/flutter

echo Build iOS app...

# Prepare Yaml file
rm -f ../pubspec.yaml
ln -s pubspec.yaml_mobile ../pubspec.yaml

# Build with: Flutter version 3.29.0, Dart version 3.7.0
flutter clean
cd ${FLUTTER_PATH}
git checkout 3.29.0
cd -
flutter doctor -v

# Prepare platform-specific files: disable flutter_libserialport
rm -f ../lib/utils/CompatUtils.dart
ln -s CompatUtils.dart.mobile ../lib/utils/CompatUtils.dart

# Build app
flutter build ios --release
