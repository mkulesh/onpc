#!/bin/bash

flutter clean
rm -rf android/.gradle

flutter build apk
cp build/app/outputs/apk/release/app-release.apk release/onpc-v2.0-release.apk

flutter clean
rm -f ios/Flutter/Generated.xcconfig
rm -f ios/Flutter/flutter_export_environment.sh
rm -rf android/.gradle
