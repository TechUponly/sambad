#!/bin/bash

echo "🔧 Updating iOS URL Scheme..."
echo ""

PLIST_FILE="ios/Runner/GoogleService-Info.plist"
INFO_PLIST="ios/Runner/Info.plist"

# Check if GoogleService-Info.plist exists
if [ ! -f "$PLIST_FILE" ]; then
    echo "❌ Error: GoogleService-Info.plist not found!"
    echo "Expected location: $PLIST_FILE"
    exit 1
fi

# Extract REVERSED_CLIENT_ID
REVERSED_ID=$(plutil -extract REVERSED_CLIENT_ID raw "$PLIST_FILE" 2>/dev/null)

if [ -z "$REVERSED_ID" ]; then
    echo "❌ Error: Could not extract REVERSED_CLIENT_ID from GoogleService-Info.plist"
    exit 1
fi

echo "📋 Found REVERSED_CLIENT_ID: $REVERSED_ID"
echo ""

# Check if it's a placeholder
if [[ "$REVERSED_ID" == *"placeholder"* ]]; then
    echo "❌ Error: REVERSED_CLIENT_ID is still a placeholder!"
    echo ""
    echo "You need to download the real GoogleService-Info.plist from Firebase Console:"
    echo "https://console.firebase.google.com/project/private-sambad/settings/general"
    echo ""
    exit 1
fi

# Get current URL scheme
CURRENT_SCHEME=$(plutil -extract CFBundleURLTypes.0.CFBundleURLSchemes.0 raw "$INFO_PLIST" 2>/dev/null)

echo "📋 Current URL Scheme in Info.plist: $CURRENT_SCHEME"
echo ""

if [ "$CURRENT_SCHEME" == "$REVERSED_ID" ]; then
    echo "✅ URL Scheme is already correct!"
    echo ""
    exit 0
fi

# Update Info.plist
echo "🔄 Updating Info.plist..."
sed -i '' "s|$CURRENT_SCHEME|$REVERSED_ID|g" "$INFO_PLIST"

# Verify the change
NEW_SCHEME=$(plutil -extract CFBundleURLTypes.0.CFBundleURLSchemes.0 raw "$INFO_PLIST" 2>/dev/null)

if [ "$NEW_SCHEME" == "$REVERSED_ID" ]; then
    echo "✅ Successfully updated URL Scheme!"
    echo ""
    echo "Old: $CURRENT_SCHEME"
    echo "New: $NEW_SCHEME"
    echo ""
    echo "📱 Next steps:"
    echo "1. Run: flutter clean"
    echo "2. Run: flutter pub get"
    echo "3. Run: cd ios && pod install && cd .."
    echo "4. Run: flutter run"
else
    echo "❌ Error: Failed to update URL Scheme"
    echo "Please update manually in Xcode or Info.plist"
    exit 1
fi
