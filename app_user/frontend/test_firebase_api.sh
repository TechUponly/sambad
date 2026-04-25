#!/bin/bash

# Firebase Phone Auth API Test Script
# This tests if Firebase Phone Authentication is working

echo "🔥 Firebase Phone Authentication API Test"
echo "=========================================="
echo ""

# Configuration - UPDATE THESE
WEB_API_KEY="AIzaSyB7d8mR41AEaMWpQ308YujKZD2HHWGy89o"  # Your Firebase Web API Key
PHONE_NUMBER="+16505551234"  # Test phone number
TEST_CODE="123456"  # Test OTP code

echo "Configuration:"
echo "  API Key: ${WEB_API_KEY:0:20}..."
echo "  Phone: $PHONE_NUMBER"
echo "  Test Code: $TEST_CODE"
echo ""

# Step 1: Send OTP
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Sending OTP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SEND_RESPONSE=$(curl -s -X POST \
  "https://identitytoolkit.googleapis.com/v1/accounts:sendVerificationCode?key=$WEB_API_KEY" \
  -H 'Content-Type: application/json' \
  -d "{
    \"phoneNumber\": \"$PHONE_NUMBER\",
    \"recaptchaToken\": \"test\"
  }")

echo "Response:"
echo "$SEND_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$SEND_RESPONSE"
echo ""

# Check for errors
if echo "$SEND_RESPONSE" | grep -q "error"; then
    echo "❌ Failed to send OTP"
    echo ""
    echo "Common issues:"
    echo "  • Phone Authentication not enabled in Firebase Console"
    echo "  • Test phone number not added"
    echo "  • Invalid API key"
    echo ""
    echo "Fix:"
    echo "  1. Go to: https://console.firebase.google.com/project/private-sambad/authentication/providers"
    echo "  2. Enable Phone provider"
    echo "  3. Add test phone: +1 650-555-1234 → Code: 123456"
    exit 1
fi

# Extract sessionInfo
SESSION_INFO=$(echo "$SEND_RESPONSE" | grep -o '"sessionInfo":"[^"]*' | sed 's/"sessionInfo":"//')

if [ -z "$SESSION_INFO" ]; then
    echo "❌ No session info received"
    exit 1
fi

echo "✅ OTP sent successfully!"
echo "Session Info: ${SESSION_INFO:0:50}..."
echo ""

# Step 2: Verify OTP
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Verifying OTP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

VERIFY_RESPONSE=$(curl -s -X POST \
  "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPhoneNumber?key=$WEB_API_KEY" \
  -H 'Content-Type: application/json' \
  -d "{
    \"sessionInfo\": \"$SESSION_INFO\",
    \"code\": \"$TEST_CODE\"
  }")

echo "Response:"
echo "$VERIFY_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$VERIFY_RESPONSE"
echo ""

# Check if successful
if echo "$VERIFY_RESPONSE" | grep -q "idToken"; then
    echo "✅ OTP verified successfully!"
    echo "✅ Firebase Phone Authentication is working!"
    echo ""
    
    # Extract user info
    USER_ID=$(echo "$VERIFY_RESPONSE" | grep -o '"localId":"[^"]*' | sed 's/"localId":"//')
    ID_TOKEN=$(echo "$VERIFY_RESPONSE" | grep -o '"idToken":"[^"]*' | sed 's/"idToken":"//')
    
    echo "User authenticated:"
    echo "  User ID: $USER_ID"
    echo "  ID Token: ${ID_TOKEN:0:50}..."
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ TEST PASSED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Firebase is configured correctly!"
    echo "If your iOS app still crashes, the issue is:"
    echo "  • Bundle ID mismatch"
    echo "  • Missing REVERSED_CLIENT_ID in Info.plist"
    echo "  • iOS app not registered in Firebase"
    echo ""
    echo "See: FIX_APP_CRASH.md for iOS-specific fixes"
else
    echo "❌ OTP verification failed"
    echo ""
    echo "Possible issues:"
    echo "  • Wrong OTP code"
    echo "  • Session expired"
    echo "  • Test phone number not configured correctly"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ TEST FAILED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
fi
