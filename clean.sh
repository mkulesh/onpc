#!/bin/bash

flutter clean

rm -rf ios/Flutter/Generated.xcconfig
rm -rf ios/Flutter/flutter_export_environment.sh
rm -rf ios/Podfile
rm -rf ios/.symlinks
rm -rf ios/Flutter/App.framework
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Generated.xcconfig
rm -rf ios/Flutter/flutter_export_environment.sh
rm -rf ios/Flutter/Flutter.podspec
rm -rf ios/Runner.xcodeproj/project.xcworkspace/xcshareddata
rm -rf ios/Podfile
rm -rf ios/Frameworks
rm -rf ios/Podfile.lock
rm -rf ios/Pods
rm -rf ios/ServiceDefinitions.json
rm -rf ios/Runner.xcworkspace/xcshareddata
rm -rf ios/Runner.xcworkspace/xcuserdata
rm -rf ios/Flutter/.last_build_id
rm -rf macos/Podfile
rm -rf macos/Podfile.lock
rm -rf macos/Pods
rm -rf macos/Runner.xcodeproj/xcuserdata
rm -rf macos/Runner.xcworkspace/xcuserdata
rm -rf macos/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
rm -rf macos/Runner.xcworkspace/xcshareddata/swiftpm
rm -rf android/.gradle
rm -rf android/app/.cxx

find . -name .DS_Store -exec rm -f {} \;
