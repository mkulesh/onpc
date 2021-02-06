#!/bin/bash

VER=`cat VERSION.txt`
APP_NAME=onpc-v${VER}-release.fc30
echo Building $APP_NAME

rm -rf ./$APP_NAME

# The Linux build can be currently done on master channel only
flutter channel master
flutter doctor
flutter build linux --release

mv ../build/linux/release/bundle ./$APP_NAME
cp ../linux/Music-Control.png ./$APP_NAME
