#!/bin/bash

echo "🔍 Checking Firebase Web Configuration..."
echo ""

# Check if firebase_options.dart exists
if [ ! -f "lib/firebase_options.dart" ]; then
    echo "❌ firebase_options.dart not found!"
    exit 1
fi

# Check web app ID
WEB_APP_ID=$(grep -A 10 "static const FirebaseOptions web" lib/firebase_options.dart | grep "appId:" | cut -d "'" -f 2)

echo "📱 Current Web App ID: $WEB_APP_ID"
echo ""

if [[ $WEB_APP_ID == *"android"* ]]; then
    echo "❌ PROBLEM: Using Android App ID for web!"
    echo ""
    echo "This will cause 400 errors on phone authentication."
    echo ""
    echo "FIX:"
    echo "1. Go to: https://console.firebase.google.com/project/private-sambad/settings/general"
    echo "2. Click 'Add app' → Web icon (</>) "
    echo "3. Register a new web app"
    echo "4. Copy the web app ID (format: 1:xxx:web:xxx)"
    echo "5. Update lib/firebase_options.dart with the new web app ID"
    echo ""
elif [[ $WEB_APP_ID == *"web"* ]]; then
    echo "✅ Using proper Web App ID"
    echo ""
else
    echo "⚠️  Unknown app ID format"
    echo ""
fi

# Check if reCAPTCHA container exists in index.html
if grep -q "recaptcha-container" web/index.html; then
    echo "✅ reCAPTCHA container found in web/index.html"
else
    echo "❌ reCAPTCHA container missing in web/index.html"
    echo "   Add: <div id=\"recaptcha-container\"></div>"
fi

echo ""
echo "📋 Checklist for Firebase Console:"
echo ""
echo "1. Phone Auth Enabled?"
echo "   → https://console.firebase.google.com/project/private-sambad/authentication/providers"
echo ""
echo "2. Authorized Domains includes 'localhost'?"
echo "   → https://console.firebase.google.com/project/private-sambad/authentication/settings"
echo ""
echo "3. Test Phone Number Added (+917045249564 → 123456)?"
echo "   → In Phone provider settings"
echo ""
echo "4. Web App Registered?"
echo "   → https://console.firebase.google.com/project/private-sambad/settings/general"
echo ""

echo "🚀 To test:"
echo "   flutter run -d chrome"
echo ""
