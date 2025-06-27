#!/usr/bin/env bash
set -e

toolchain build python3
toolchain create myapp bluetooth_app.py
cd myapp

# Fix the error
toolchain pip install cython
toolchain pip install -r ../requirements.txt || true

toolchain build kivy
toolchain build myapp

xcodebuild -workspace myapp.xcodeproj/project.xcworkspace \
           -scheme myapp \
           -configuration Release \
           -sdk iphoneos \
           archive -archivePath build/myapp.xcarchive

xcodebuild -exportArchive \
           -archivePath build/myapp.xcarchive \
           -exportOptionsPlist ../ExportOptions.plist \
           -exportPath build
