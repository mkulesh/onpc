#!/bin/bash

VER=`cat VERSION.txt`
APP_NAME=MusicControl-v${VER}-linux-x86_64
echo Building $APP_NAME

rm -rf ./$APP_NAME
rm -rf ${APP_NAME}.zip

# The Linux build can be currently done on master channel only
flutter clean
flutter channel master
flutter doctor
flutter build linux --release

mv ../build/linux/release/bundle ./$APP_NAME
cp ../linux/Music-Control.png ./$APP_NAME
zip -r ${APP_NAME}.zip ./$APP_NAME
