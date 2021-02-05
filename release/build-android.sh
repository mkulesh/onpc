#!/bin/bash

flutter channel stable
flutter doctor
flutter build apk --release
cp ../build/app/outputs/apk/release/app-release.apk onpc-v2.9.5-release.apk
