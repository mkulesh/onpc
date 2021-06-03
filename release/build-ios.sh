#!/bin/bash

# Build with Flutter version 1.22.6, Dart version 2.10.5
# cd flutter
# git checkout 1.22.6

flutter clean
flutter doctor
flutter build ios --release
