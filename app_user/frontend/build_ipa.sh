#!/bin/bash

set -e

echo "📦 iOS IPA Build Script"
echo "======================="
echo ""

cd "$(dirname "$0")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Pre-build checks..."
echo ""

# Check Bundle ID
XCODE_BUNDLE=$(grep -m 1 "PRODUCT_BUNDLE_IDENTIFIER = " ios/Runner.xcodeproj/project.pbxproj | sed 's/.*= \(.*\);/\1/' | tr -d ' ')
FIREBASE_BUNDLE=$(plutil -extract BUNDLE_ID raw ios/Runner/GoogleService-Info.plist 2>/dev/null)

echo "Bundle IDs:"
echo "  Xcode:    $XCODE_BUNDLE"
echo "  Firebase: $FIREBASE_BUNDLE"

if [ "$XCODE_BUNDLE" = "$FIREBASE_BUNDLE" ]; then
    echo -e "  ${GREEN}✅ Bundle IDs match${NC}"
else
    echo -e "  ${RED}❌ Bundle IDs don't match${NC}"
    exit 1
fi
echo ""

# Check REVERSED_CLIENT_ID
REVERSED_ID=$(plutil -extract REVERSED_CLIENT_ID raw ios/Runner/GoogleService-Info.plist 2>/dev/null)
if [[ "$REVERSED_ID" == *"placeholder"* ]]; then
    echo -e "${YELLOW}⚠️  Warning: Using placeholder REVERSED_CLIENT_ID${NC}"
    echo "   Phone authentication may not work properly"
    echo "   Download real GoogleService-Info.plist from Firebase Console"
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "🧹 Cleaning previous builds..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🍎 Installing CocoaPods..."
cd ios
pod install
cd ..

echo "🔨 Building iOS app (release mode)..."
flutter build ios --release --no-codesign

echo ""
echo "📱 Creating IPA file..."
echo ""

# Create Payload directory
mkdir -p build/ios/iphoneos/Payload

# Copy app to Payload
cp -r build/ios/iphoneos/Runner.app build/ios/iphoneos/Payload/

# Create IPA
cd build/ios/iphoneos
zip -r Runner.ipa Payload
cd ../../..

# Move IPA to root
mv build/ios/iphoneos/Runner.ipa ./PrivateSambad.ipa

# Cleanup
rm -rf build/ios/iphoneos/Payload

echo ""
echo -e "${GREEN}✅ IPA file created successfully!${NC}"
echo ""
echo "📍 Location: $(pwd)/PrivateSambad.ipa"
echo ""
echo "📊 File info:"
ls -lh PrivateSambad.ipa
echo ""

echo "⚠️  IMPORTANT NOTES:"
echo ""
echo "1. This IPA is NOT CODE SIGNED"
echo "   - Cannot be installed on real devices"
echo "   - For testing only"
echo ""
echo "2. To create a signed IPA for distribution:"
echo "   a. Open Xcode: open ios/Runner.xcworkspace"
echo "   b. Select your development team"
echo "   c. Product → Archive"
echo "   d. Distribute App → Ad Hoc or App Store"
echo ""
echo "3. For TestFlight/App Store:"
echo "   - You need an Apple Developer account"
echo "   - Configure signing in Xcode"
echo "   - Use Xcode's Archive feature"
echo ""
echo "4. Phone Authentication:"
echo "   - Download real GoogleService-Info.plist from Firebase"
echo "   - Enable Phone Auth in Firebase Console"
echo "   - Add test phone numbers or configure APNs"
echo ""
echo "📖 See IPA_BUILD_GUIDE.md for detailed instructions"
