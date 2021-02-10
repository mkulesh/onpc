#!/bin/bash

VER=`cat VERSION.txt`
APP_NAME=MusicControl-v${VER}-android.apk
echo Building $APP_NAME

rm -rf ./$APP_NAME

flutter clean
flutter channel stable
flutter doctor
flutter build apk --release

mv ../build/app/outputs/apk/release/app-release.apk ./$APP_NAME
