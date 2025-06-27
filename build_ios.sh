#!/usr/bin/env bash
set -e

# 1) Create the Xcode project
toolchain create MyApp bluetooth_app.py

cd MyApp

# ✅ FIX: Install Cython inside toolchain’s internal Python environment
toolchain pip install cython

# Install your app dependencies
toolchain pip install -r ../requirements.txt

# Build Python and Kivy
toolchain build python3 kivy

# Build your app
toolchain build MyApp

# Archive & export .ipa
xcodebuild -workspace MyApp.xcodeproj/project.xcworkspace \
           -scheme MyApp \
           -configuration Release \
           -sdk iphoneos \
           archive -archivePath build/MyApp.xcarchive

xcodebuild -exportArchive \
           -archivePath build/MyApp.xcarchive \
           -exportOptionsPlist ../ExportOptions.plist \
           -exportPath build
