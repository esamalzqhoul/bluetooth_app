#!/usr/bin/env bash
set -e

# === Step 0: Install required build tools ===
pip install --upgrade pip setuptools wheel
pip install cython autoconf automake

# === Step 1: Create the Xcode project ===
toolchain create MyApp bluetooth_app.py

cd MyApp

# === Step 2: Install Python dependencies into iOS build ===
toolchain pip install -r ../requirements.txt

# === Step 3: Build Kivy and your app ===
toolchain build python3 kivy
toolchain build MyApp

# === Step 4: Archive the app and export the IPA ===
xcodebuild -workspace MyApp.xcodeproj/project.xcworkspace \
           -scheme MyApp \
           -configuration Release \
           -sdk iphoneos \
           archive -archivePath build/MyApp.xcarchive

xcodebuild -exportArchive \
           -archivePath build/MyApp.xcarchive \
           -exportOptionsPlist ../ExportOptions.plist \
           -exportPath build
