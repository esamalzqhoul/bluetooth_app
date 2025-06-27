#!/usr/bin/env bash
set -e

# Ensure toolchain is up to date
toolchain recipes

# Step 0: Build Python for iOS (once)
toolchain build python3

# Step 1: Create the iOS project
toolchain create MyApp bluetooth_app.py

cd MyApp

# ✅ Step 2: Install Cython directly into iOS Python env
toolchain pip install cython

# ✅ Optional: install other Python deps (won’t break if empty)
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
