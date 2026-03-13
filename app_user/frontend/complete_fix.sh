#!/bin/bash

set -e  # Exit on error

echo "🔧 Complete OTP Fix Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if GoogleService-Info.plist exists in Downloads
DOWNLOADS_PLIST="$HOME/Downloads/GoogleService-Info.plist"
RUNNER_PLIST="ios/Runner/GoogleService-Info.plist"

if [ ! -f "$DOWNLOADS_PLIST" ]; then
    echo "❌ GoogleService-Info.plist not found in Downloads folder!"
    echo ""
    echo "📥 Please download it first:"
    echo ""
    echo "1. Open: https://console.firebase.google.com/project/private-sambad/settings/general"
    echo "2. Find iOS app with Bundle ID: com.shamrai.sambad"
    echo "3. Download GoogleService-Info.plist"
    echo "4. Save to Downloads folder"
    echo "5. Run this script again"
    echo ""
    exit 1
fi

echo "✅ Found GoogleService-Info.plist in Downloads"
echo ""

# Backup old file
if [ -f "$RUNNER_PLIST" ]; then
    echo "📦 Backing up old GoogleService-Info.plist..."
    cp "$RUNNER_PLIST" "${RUNNER_PLIST}.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Copy new file
echo "📋 Copying new GoogleService-Info.plist..."
cp "$DOWNLOADS_PLIST" "$RUNNER_PLIST"
echo "✅ File copied"
echo ""

# Check if it's still a placeholder
CLIENT_ID=$(plutil -extract CLIENT_ID raw "$RUNNER_PLIST" 2>/dev/null)
if [[ "$CLIENT_ID" == *"placeholder"* ]]; then
    echo "❌ Error: The downloaded file still has placeholder credentials!"
    echo ""
    echo "This means you downloaded the wrong file or the iOS app"
    echo "is not properly configured in Firebase Console."
    echo ""
    echo "Please:"
    echo "1. Go to Firebase Console"
    echo "2. Make sure iOS app exists with Bundle ID: com.shamrai.sambad"
    echo "3. Download the correct GoogleService-Info.plist"
    echo ""
    exit 1
fi

echo "✅ GoogleService-Info.plist looks valid"
echo ""

# Update URL Scheme
echo "🔄 Updating URL Scheme..."
./update_url_scheme.sh
echo ""

# Verify configuration
echo "🔍 Verifying configuration..."
./verify_firebase_config.sh
echo ""

# Check if verification passed
if [ $? -ne 0 ]; then
    echo "❌ Verification failed. Please check the errors above."
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎉 Configuration complete!"
echo ""
echo "📱 Next steps:"
echo ""
echo "1. Clean and rebuild:"
echo "   flutter clean"
echo "   flutter pub get"
echo "   cd ios && pod install && cd .."
echo ""
echo "2. Run the app:"
echo "   flutter run"
echo ""
echo "3. Test OTP:"
echo "   • Enter: +917045249564"
echo "   • Click 'Send OTP' (should NOT crash)"
echo "   • Enter: 123456"
echo "   • Should log in successfully"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Would you like to rebuild now? (y/n)"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo ""
    echo "🔨 Rebuilding..."
    echo ""
    
    flutter clean
    flutter pub get
    cd ios && pod install && cd ..
    
    echo ""
    echo "✅ Rebuild complete!"
    echo ""
    echo "Run: flutter run"
    echo ""
else
    echo ""
    echo "👍 Okay! Run these commands when ready:"
    echo ""
    echo "flutter clean && flutter pub get && cd ios && pod install && cd .."
    echo "flutter run"
    echo ""
fi
