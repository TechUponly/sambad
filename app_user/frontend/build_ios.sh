#!/bin/bash

# iOS Build Script for Flutter App
# This script builds the iOS app for release

set -e

echo "🚀 Starting iOS build process..."

# Navigate to frontend directory
cd "$(dirname "$0")"

echo "📦 Getting Flutter dependencies..."
flutter pub get

echo "🧹 Cleaning previous builds..."
flutter clean

echo "📱 Installing iOS pods..."
cd ios
pod install
cd ..

echo "📱 Building iOS app (release mode)..."
flutter build ios --release

echo "✅ iOS build completed successfully!"
echo ""
echo "📍 Build location: build/ios/iphoneos/Runner.app"
echo ""
echo "Next steps:"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. Select your development team in Signing & Capabilities"
echo "3. Connect your iOS device or select a simulator"
echo "4. Click 'Product > Archive' to create an archive for App Store"
echo "5. Or click 'Run' to install on your device for testing"
