#!/usr/bin/env bash
set -e

# Optional: Show recipes
toolchain recipes

# Step 0: Build Python for iOS
toolchain build python3

# Step 1: Create iOS project
toolchain create MyApp bluetooth_app.py

# Step 2: Change into the created project (called myapp-ios regardless of name)
cd myapp-ios

# Step 3: Build python AGAIN inside app folder (required for pip to work)
toolchain build python3

# Step 4: Install Python deps (if any)
if [ -f ../requirements.txt ]; then
    toolchain pip install -r ../requirements.txt
else
    echo "No requirements.txt found, skipping pip install"
fi

# Step 5: Build Kivy and the app
toolchain build kivy
toolchain build MyApp

# Step 6: Archive & export .ipa
xcodebuild -workspace myapp.xcodeproj/project.xcworkspace \
           -scheme MyApp \
           -configuration Release \
           -sdk iphoneos \
           archive -archivePath build/MyApp.xcarchive

xcodebuild -exportArchive \
           -archivePath build/MyApp.xcarchive \
           -exportOptionsPlist ../ExportOptions.plist \
           -exportPath build
