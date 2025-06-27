#!/usr/bin/env bash
set -e

ROOT_DIR=$(pwd)

# Step 0: Build Python for iOS
toolchain build python3

# Step 1: Create the iOS project
toolchain create myapp bluetooth_app.py
cd myapp

# ✅ Step 2a: Make sure cython is available
toolchain pip install cython

# ✅ Step 2b: Install other dependencies
toolchain pip install -r "$ROOT_DIR/requirements.txt" || true

# Step 3: Build Kivy and app
toolchain build kivy
toolchain build myapp

# Step 4: Archive & export .ipa
xcodebuild -workspace myapp.xcodeproj/project.xcworkspace \
           -scheme myapp \
           -configuration Release \
           -sdk iphoneos \
           archive -archivePath build/myapp.xcarchive

xcodebuild -exportArchive \
           -archivePath build/myapp.xcarchive \
           -exportOptionsPlist "$ROOT_DIR/ExportOptions.plist" \
           -exportPath build
