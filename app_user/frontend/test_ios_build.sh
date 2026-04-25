#!/bin/bash

echo "🧪 Testing iOS Build"
echo "===================="
echo ""

cd "$(dirname "$0")"

echo "1️⃣ Checking Bundle ID..."
XCODE_BUNDLE=$(grep -m 1 "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | sed 's/.*= \(.*\);/\1/')
FIREBASE_BUNDLE=$(plutil -extract BUNDLE_ID raw ios/Runner/GoogleService-Info.plist 2>/dev/null)

echo "   Xcode:    $XCODE_BUNDLE"
echo "   Firebase: $FIREBASE_BUNDLE"

if [ "$XCODE_BUNDLE" = "$FIREBASE_BUNDLE" ]; then
    echo "   ✅ Bundle IDs match!"
else
    echo "   ⚠️  Bundle IDs don't match - this may cause issues"
fi
echo ""

echo "2️⃣ Checking REVERSED_CLIENT_ID..."
if grep -q "REVERSED_CLIENT_ID" ios/Runner/GoogleService-Info.plist; then
    REVERSED_ID=$(plutil -extract REVERSED_CLIENT_ID raw ios/Runner/GoogleService-Info.plist 2>/dev/null)
    echo "   Found: $REVERSED_ID"
    
    if [[ "$REVERSED_ID" == *"placeholder"* ]]; then
        echo "   ⚠️  Using placeholder - download real config from Firebase Console"
    else
        echo "   ✅ Real REVERSED_CLIENT_ID configured"
    fi
else
    echo "   ❌ REVERSED_CLIENT_ID missing"
fi
echo ""

echo "3️⃣ Checking Firebase configuration..."
if [ -f "lib/firebase_options.dart" ]; then
    if grep -q "case TargetPlatform.iOS:" lib/firebase_options.dart; then
        echo "   ✅ iOS Firebase config present"
    else
        echo "   ❌ iOS Firebase config missing"
    fi
else
    echo "   ❌ firebase_options.dart not found"
fi
echo ""

echo "4️⃣ Checking permissions in Info.plist..."
PERMS=("NSContactsUsageDescription" "NSCameraUsageDescription" "NSPhotoLibraryUsageDescription")
for perm in "${PERMS[@]}"; do
    if grep -q "$perm" ios/Runner/Info.plist; then
        echo "   ✅ $perm"
    else
        echo "   ❌ $perm missing"
    fi
done
echo ""

echo "5️⃣ Checking CocoaPods..."
if [ -d "ios/Pods" ]; then
    echo "   ✅ Pods installed"
else
    echo "   ⚠️  Pods not installed - run: cd ios && pod install"
fi
echo ""

echo "📱 Ready to build?"
echo ""
echo "To run on device/simulator:"
echo "  flutter run"
echo ""
echo "To build release:"
echo "  flutter build ios --release"
echo ""
echo "To open in Xcode:"
echo "  open ios/Runner.xcworkspace"
echo ""

echo "⚠️  Remember:"
echo "  1. Download real GoogleService-Info.plist from Firebase"
echo "  2. Enable Phone Auth in Firebase Console"
echo "  3. Add test phone numbers for testing"
echo ""
echo "📖 See COMPLETE_IOS_SETUP.md for detailed instructions"
