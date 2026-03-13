#!/bin/bash

echo "🔧 iOS Phone Authentication Fix Script"
echo "========================================"
echo ""

cd "$(dirname "$0")"

echo "📋 Step 1: Checking GoogleService-Info.plist..."
if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "✅ GoogleService-Info.plist found"
    
    # Check for REVERSED_CLIENT_ID
    if grep -q "REVERSED_CLIENT_ID" ios/Runner/GoogleService-Info.plist; then
        echo "✅ REVERSED_CLIENT_ID found"
        
        # Extract REVERSED_CLIENT_ID
        REVERSED_ID=$(plutil -extract REVERSED_CLIENT_ID raw ios/Runner/GoogleService-Info.plist 2>/dev/null)
        
        if [ -n "$REVERSED_ID" ]; then
            echo "📝 REVERSED_CLIENT_ID: $REVERSED_ID"
            echo ""
            echo "⚠️  ACTION REQUIRED:"
            echo "Update Info.plist with this URL scheme:"
            echo "<string>$REVERSED_ID</string>"
            echo ""
        fi
    else
        echo "❌ REVERSED_CLIENT_ID not found!"
        echo ""
        echo "⚠️  ACTION REQUIRED:"
        echo "1. Go to Firebase Console: https://console.firebase.google.com/"
        echo "2. Select project: private-sambad"
        echo "3. Project Settings → Your apps → iOS app"
        echo "4. Download fresh GoogleService-Info.plist"
        echo "5. Replace ios/Runner/GoogleService-Info.plist"
        echo ""
    fi
else
    echo "❌ GoogleService-Info.plist not found!"
fi

echo "🧹 Step 2: Cleaning build..."
flutter clean

echo "📦 Step 3: Getting dependencies..."
flutter pub get

echo "🍎 Step 4: Reinstalling pods..."
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

echo ""
echo "✅ Setup complete!"
echo ""
echo "📱 Next steps:"
echo "1. Verify URL scheme in Info.plist (see above)"
echo "2. Enable Phone Auth in Firebase Console"
echo "3. Configure APNs OR add test phone numbers"
echo "4. Run: flutter run"
echo ""
echo "📖 For detailed instructions, see: FIX_PHONE_AUTH_IOS.md"
