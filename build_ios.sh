#!/usr/bin/env bash
set -e

# Step 0: Build Python for iOS (only once)
toolchain build python3

# Step 1: Create the iOS project
toolchain create MyApp bluetooth_app.py

cd MyApp

# ✅ Step 2: Install Cython into the iOS toolchain environment
toolchain pip install cython

# Optional: install other Python deps
toolchain pip install -r ../requirements.txt || true

# Step 3: Build Kivy and your app
toolchain build kivy
toolchain build MyApp

# Step 4: Archive & export .ipa
xcodebuild -workspace MyApp.xcodeproj/project.xcworkspace \
           -scheme MyApp \
           -configuration Release \
           -sdk iphoneos \
           archive -archivePath build/MyApp.xcarchive

xcodebuild -exportArchive \
           -archivePath build/MyApp.xcarchive \
           -exportOptionsPlist ../ExportOptions.plist \
           -exportPath build
