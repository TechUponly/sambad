#!/bin/bash

echo "🧪 Testing OTP Setup for Private Sambad"
echo "========================================"
echo ""

cd "$(dirname "$0")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "1️⃣ Checking REVERSED_CLIENT_ID..."
REVERSED_ID=$(plutil -extract REVERSED_CLIENT_ID raw ios/Runner/GoogleService-Info.plist 2>/dev/null)

if [ -z "$REVERSED_ID" ]; then
    echo -e "   ${RED}❌ REVERSED_CLIENT_ID not found${NC}"
    echo "   Action: Download GoogleService-Info.plist from Firebase Console"
elif [[ "$REVERSED_ID" == *"placeholder"* ]]; then
    echo -e "   ${YELLOW}⚠️  Using placeholder: $REVERSED_ID${NC}"
    echo "   Action: Download real GoogleService-Info.plist from Firebase Console"
else
    echo -e "   ${GREEN}✅ Found: $REVERSED_ID${NC}"
fi
echo ""

echo "2️⃣ Checking URL Scheme in Info.plist..."
if grep -q "$REVERSED_ID" ios/Runner/Info.plist 2>/dev/null; then
    echo -e "   ${GREEN}✅ URL Scheme configured correctly${NC}"
else
    echo -e "   ${RED}❌ URL Scheme not matching${NC}"
    echo "   Action: Update CFBundleURLSchemes in Info.plist with:"
    echo "   $REVERSED_ID"
fi
echo ""

echo "3️⃣ Checking Firebase Configuration..."
PROJECT_ID=$(plutil -extract PROJECT_ID raw ios/Runner/GoogleService-Info.plist 2>/dev/null)
BUNDLE_ID=$(plutil -extract BUNDLE_ID raw ios/Runner/GoogleService-Info.plist 2>/dev/null)

echo "   Project ID: $PROJECT_ID"
echo "   Bundle ID: $BUNDLE_ID"
echo ""

echo "4️⃣ Firebase Console Checklist:"
echo ""
echo "   📋 Go to: https://console.firebase.google.com/project/$PROJECT_ID/authentication/providers"
echo ""
echo "   Check these items:"
echo "   [ ] Phone provider is ENABLED (should show green toggle)"
echo "   [ ] Test phone numbers are added"
echo "       Example: +1 650-555-1234 → Code: 123456"
echo ""

echo "5️⃣ Quick Test Instructions:"
echo ""
echo "   1. Run the app:"
echo "      flutter run"
echo ""
echo "   2. Enter test phone number:"
echo "      +1 650-555-1234"
echo ""
echo "   3. Click 'Send OTP'"
echo ""
echo "   4. Enter test code:"
echo "      123456"
echo ""
echo "   5. Should log in successfully!"
echo ""

echo "6️⃣ If OTP Still Doesn't Work:"
echo ""
echo "   • Open in Xcode for detailed errors:"
echo "     open ios/Runner.xcworkspace"
echo ""
echo "   • Check Firebase Console:"
echo "     - Authentication → Sign-in method → Phone (enabled?)"
echo "     - Authentication → Sign-in method → Test phone numbers (added?)"
echo ""
echo "   • Run with verbose output:"
echo "     flutter run --verbose"
echo ""

echo "📖 For detailed troubleshooting, see: FIX_OTP_ISSUE.md"
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ "$REVERSED_ID" == *"placeholder"* ]]; then
    echo -e "${YELLOW}⚠️  Using placeholder config - OTP may not work${NC}"
    echo ""
    echo "QUICK FIX:"
    echo "1. Enable Phone Auth in Firebase Console"
    echo "2. Add test phone numbers"
    echo "3. Test with: +1 650-555-1234 / Code: 123456"
else
    echo -e "${GREEN}✅ Configuration looks good!${NC}"
    echo ""
    echo "Make sure:"
    echo "1. Phone Auth is enabled in Firebase Console"
    echo "2. Test phone numbers are added"
    echo "3. Then test the app"
fi
