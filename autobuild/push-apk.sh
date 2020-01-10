#!/bin/sh

APK_VERSION=1.9

echo "Generated APK"
pwd; ls -l ./app/build/outputs/apk

# Checkout autobuild branch
cd ..
git clone https://github.com/mkulesh/onpc.git --branch autobuild --single-branch onpc_autobuild
cd onpc_autobuild

# Copy newly created APK into the target directory
mv ../onpc/app/build/outputs/apk/debug/onpc-v${APK_VERSION}-debug.apk ./autobuild
echo "Target APK"
pwd; ls -l ./autobuild

# Setup git for commit and push
git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"
git remote add origin-master https://${AUTOBUILD_TOKEN}@github.com/mkulesh/onpc > /dev/null 2>&1
git add ./autobuild/onpc-v${APK_VERSION}-debug.apk

# We don’t want to run a build for a this commit in order to avoid circular builds: 
# add [ci skip] to the git commit message
git commit --message "Snapshot autobuild N.$TRAVIS_BUILD_NUMBER [ci skip]"
git push origin-master

