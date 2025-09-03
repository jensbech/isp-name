#!/bin/bash

# Build script to create a proper macOS app bundle

APP_NAME="ISPOrgMenuBarApp"
VERSION="1.0.0"
BUILD_DIR=".build/arm64-apple-macosx/release"
RELEASE_DIR="release/${VERSION}"
APP_BUNDLE="${RELEASE_DIR}/${APP_NAME}.app"

echo "Building ${APP_NAME} for release..."

# Clean and build
swift build -c release

# Create app bundle structure
echo "Creating app bundle structure..."
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy the executable
cp "${BUILD_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/"

# Copy Info.plist
cp "Resources/Info.plist" "${APP_BUNDLE}/Contents/"

# Make executable
chmod +x "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

echo "App bundle created at: ${APP_BUNDLE}"

# Create a zip for distribution
cd "${RELEASE_DIR}"
zip -r "${APP_NAME}-${VERSION}-macOS.zip" "${APP_NAME}.app"
cd - > /dev/null

echo "Distribution zip created: ${RELEASE_DIR}/${APP_NAME}-${VERSION}-macOS.zip"
echo ""
echo "To install:"
echo "1. Extract the zip file"
echo "2. Move ${APP_NAME}.app to your Applications folder"
echo "3. Launch it from Applications or Spotlight"
