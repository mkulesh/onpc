#!/bin/bash

flutter clean
rm -rf android/.gradle

flutter build apk
cp build/app/outputs/apk/release/app-release.apk release/onpc-v2.1-release.apk

flutter clean
rm -f ios/Flutter/Generated.xcconfig
rm -f ios/Flutter/flutter_export_environment.sh
rm -rf android/.gradle

rm -rf ios/.symlinks/
rm -rf ios/Flutter/App.framework/
rm -rf ios/Flutter/Flutter.framework/
rm -rf ios/Flutter/Generated.xcconfig
rm -rf ios/Flutter/flutter_export_environment.sh
rm -rf ios/Flutter/Flutter.podspec
rm -rf ios/Podfile
rm -rf ios/Frameworks
rm -rf ios/Podfile.lock
rm -rf ios/Pods/
rm -rf ios/ServiceDefinitions.json
rm -rf ios/Runner.xcworkspace/xcshareddata/
rm -rf ios/Runner.xcworkspace/xcuserdata/
find . -name .DS_Store -exec rm -f {} \;

