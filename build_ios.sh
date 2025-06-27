#!/usr/bin/env bash
set -e

# === SETUP VENV ===
python3 -m venv venv
source venv/bin/activate

# === UPGRADE PIP AND INSTALL CYTHON ===
pip install --upgrade pip
pip install cython==3.0.11

# === INSTALL DEPENDENCIES ===
pip install kivy-ios

# === CREATE XCODE PROJECT ===
toolchain create MyApp bluetooth_app.py
cd MyApp

# === INSTALL PYTHON REQUIREMENTS ===
toolchain pip install -r ../requirements.txt

# === BUILD PYTHON + KIVY + APP ===
toolchain build python3 kivy
toolchain build MyApp

# === ARCHIVE & EXPORT .IPA ===
xcodebuild -workspace MyApp.xcodeproj/project.xcworkspace \
           -scheme MyApp \
           -configuration Release \
           -sdk iphoneos \
           archive -archivePath build/MyApp.xcarchive

xcodebuild -exportArchive \
           -archivePath build/MyApp.xcarchive \
           -exportOptionsPlist ../ExportOptions.plist \
           -exportPath build
