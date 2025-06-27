#!/usr/bin/env bash
set -e

# Optional: list available recipes
toolchain recipes

# Step 0: Build Python for iOS (required before project creation)
toolchain build python3

# Step 1: Create the iOS project
toolchain create MyApp bluetooth_app.py

# IMPORTANT: Kivy-iOS creates a folder called "myapp-ios" regardless of input name
cd myapp-ios

# Step 2: Install Python deps into the iOS build
if [ -f ../requirements.txt ]; then
    toolchain pip install -r ../requirements.txt
else
    echo "No requirements.txt found, skipping Python deps install"
fi

# Step 3: Build Kivy and your app
toolchain build kivy
toolchain build MyApp

# Step 4: Archive & export .ipa
xcodebuild -workspace myapp.xcodeproj/project.xcworkspace \
           -scheme MyApp \
           -configuration Release \
           -sdk iphoneos \
           archive -archivePath build/MyApp.xcarchive

xcodebuild -exportArchive \
           -archivePath build/MyApp.xcarchive \
           -exportOptionsPlist ../ExportOptions.plist \
           -exportPath build
