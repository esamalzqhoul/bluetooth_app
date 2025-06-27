#!/usr/bin/env bash
set -e

# Optional: ensure recipe list is up to date
toolchain recipes

# Step 0: Build Python for iOS (needed once)
toolchain build python3

# Step 1: Create the iOS project
toolchain create MyApp bluetooth_app.py

cd MyApp

# ✅ Step 2: Install cython inside the toolchain's Python env
toolchain pip install cython

# ✅ Step 3: Install other requirements
toolchain pip install -r ../requirements.txt || true

# Step 4: Build Kivy and your app
toolchain build kivy
toolchain build MyApp

# Step 5: Archive & export .ipa
xcodebuild -workspace MyApp.xcodeproj/project.xcworkspace \
           -scheme MyApp \
           -configuration Release \
           -sdk iphoneos \
           archive -archivePath build/MyApp.xcarchive

xcodebuild -exportArchive \
           -archivePath build/MyApp.xcarchive \
           -exportOptionsPlist ../ExportOptions.plist \
           -exportPath build
