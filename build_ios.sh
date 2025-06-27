#!/usr/bin/env bash
set -e

toolchain recipes 
# Step 0: Build Python for iOS (required before project creation)
toolchain build python3

# Step 1: Create the iOS project
toolchain create MyApp bluetooth_app.py

cd MyApp

# Step 2: Install Python deps into the iOS build
toolchain pip install -r ../requirements.txt || true  # don't fail if requirements.txt is empty

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
