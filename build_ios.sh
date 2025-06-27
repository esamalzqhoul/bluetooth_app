#!/usr/bin/env bash
set -e

# 1) Create the Xcode project
toolchain create MyApp bluetooth_app.py

cd MyApp

# 2) Install a compatible Cython version inside the toolchain
toolchain pip install cython==3.0.11

# 3) Make sure `cython` executable is in PATH for the build
ln -s "$(toolchain pip show cython | grep Location | cut -d' ' -f2)/cython" /usr/local/bin/cython || true

# 4) Install your app dependencies
toolchain pip install -r ../requirements.txt

# 5) Build Python and Kivy
toolchain build python3 kivy

# 6) Build your app
toolchain build MyApp

# 7) Archive & export .ipa
xcodebuild -workspace MyApp.xcodeproj/project.xcworkspace \
           -scheme MyApp \
           -configuration Release \
           -sdk iphoneos \
           archive -archivePath build/MyApp.xcarchive

xcodebuild -exportArchive \
           -archivePath build/MyApp.xcarchive \
           -exportOptionsPlist ../ExportOptions.plist \
           -exportPath build
