#!/usr/bin/env bash
set -e

# 1) Create the Xcode project
toolchain create MyApp bluetooth_app.py

cd MyApp

# 2) Install Python deps into the iOS build
toolchain pip install -r ../requirements.txt

# 3) Build Kivy and your app
toolchain build python3 kivy
toolchain build MyApp

# 4) Archive & export .ipa
xcodebuild -workspace MyApp.xcodeproj/project.xcworkspace \
           -scheme MyApp \
           -configuration Release \
           -sdk iphoneos \
           archive -archivePath build/MyApp.xcarchive

xcodebuild -exportArchive \
           -archivePath build/MyApp.xcarchive \
           -exportOptionsPlist ../ExportOptions.plist \
           -exportPath build
