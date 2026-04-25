#!/bin/bash

echo "🔍 Verifying Firebase iOS Configuration..."
echo ""

PLIST_FILE="ios/Runner/GoogleService-Info.plist"
INFO_PLIST="ios/Runner/Info.plist"

if [ ! -f "$PLIST_FILE" ]; then
    echo "❌ GoogleService-Info.plist not found!"
    exit 1
fi

echo "📋 Current Configuration:"
echo "========================"

# Extract values
BUNDLE_ID=$(plutil -extract BUNDLE_ID raw "$PLIST_FILE" 2>/dev/null)
CLIENT_ID=$(plutil -extract CLIENT_ID raw "$PLIST_FILE" 2>/dev/null)
REVERSED_CLIENT_ID=$(plutil -extract REVERSED_CLIENT_ID raw "$PLIST_FILE" 2>/dev/null)
PROJECT_ID=$(plutil -extract PROJECT_ID raw "$PLIST_FILE" 2>/dev/null)

echo "Bundle ID: $BUNDLE_ID"
echo "Project ID: $PROJECT_ID"
echo "Client ID: $CLIENT_ID"
echo "Reversed Client ID: $REVERSED_CLIENT_ID"
echo ""

# Check for placeholder
if [[ "$CLIENT_ID" == *"placeholder"* ]]; then
    echo "❌ PROBLEM: Using placeholder CLIENT_ID"
    echo ""
    echo "🔧 FIX REQUIRED:"
    echo "1. Go to: https://console.firebase.google.com/project/private-sambad/settings/general"
    echo "2. Download real GoogleService-Info.plist for Bundle ID: com.shamrai.sambad"
    echo "3. Replace ios/Runner/GoogleService-Info.plist"
    echo "4. Run this script again"
    echo ""
    exit 1
fi

if [[ "$REVERSED_CLIENT_ID" == *"placeholder"* ]]; then
    echo "❌ PROBLEM: Using placeholder REVERSED_CLIENT_ID"
    echo ""
    echo "🔧 FIX REQUIRED:"
    echo "1. Download real GoogleService-Info.plist from Firebase Console"
    echo "2. Replace ios/Runner/GoogleService-Info.plist"
    echo "3. Run this script again"
    echo ""
    exit 1
fi

echo "✅ GoogleService-Info.plist looks good!"
echo ""

# Check Info.plist URL scheme
echo "🔍 Checking Info.plist URL Scheme..."
URL_SCHEME=$(plutil -extract CFBundleURLTypes.0.CFBundleURLSchemes.0 raw "$INFO_PLIST" 2>/dev/null)

echo "URL Scheme in Info.plist: $URL_SCHEME"
echo ""

if [[ "$URL_SCHEME" == *"placeholder"* ]]; then
    echo "❌ PROBLEM: Info.plist still has placeholder URL scheme"
    echo ""
    echo "🔧 FIX:"
    echo "Run this command to update Info.plist:"
    echo ""
    echo "sed -i '' 's/com.googleusercontent.apps.1046904512204-placeholder/$REVERSED_CLIENT_ID/g' ios/Runner/Info.plist"
    echo ""
    exit 1
fi

if [ "$URL_SCHEME" != "$REVERSED_CLIENT_ID" ]; then
    echo "⚠️  WARNING: URL Scheme mismatch!"
    echo "GoogleService-Info.plist has: $REVERSED_CLIENT_ID"
    echo "Info.plist has: $URL_SCHEME"
    echo ""
    echo "🔧 FIX:"
    echo "Run this command:"
    echo ""
    echo "sed -i '' 's/$URL_SCHEME/$REVERSED_CLIENT_ID/g' ios/Runner/Info.plist"
    echo ""
    exit 1
fi

echo "✅ Info.plist URL Scheme matches!"
echo ""
echo "🎉 Configuration looks correct!"
echo ""
echo "📱 Next Steps:"
echo "1. Make sure Phone Auth is enabled in Firebase Console"
echo "2. Run: flutter clean && flutter pub get"
echo "3. Run: cd ios && pod install && cd .."
echo "4. Run: flutter run"
echo ""
echo "🔗 Firebase Console:"
echo "   https://console.firebase.google.com/project/private-sambad/authentication/providers"
