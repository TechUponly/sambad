# Test Firebase Phone Authentication with Postman

## Overview

You can test Firebase Phone Authentication using the Firebase REST API without needing the iOS app.

## Prerequisites

1. Firebase Web API Key
2. Phone Authentication enabled in Firebase Console
3. Test phone numbers configured (recommended for testing)

## Get Your Firebase Web API Key

1. Go to: https://console.firebase.google.com/project/private-sambad/settings/general
2. Scroll to "Web API Key"
3. Copy the key (looks like: `AIzaSyB7d8mR41AEaMWpQ308YujKZD2HHWGy89o`)

## Method 1: Test with Test Phone Numbers (Easiest)

### Step 1: Add Test Phone Numbers in Firebase

1. Go to: https://console.firebase.google.com/project/private-sambad/authentication/providers
2. Enable Phone provider
3. Add test phone numbers:
   - Phone: `+1 650-555-1234`
   - Code: `123456`
4. Save

### Step 2: Send OTP Request (Postman)

**Endpoint:**
```
POST https://identitytoolkit.googleapis.com/v1/accounts:sendVerificationCode?key=YOUR_WEB_API_KEY
```

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "phoneNumber": "+16505551234",
  "recaptchaToken": "test"
}
```

**Response (Success):**
```json
{
  "sessionInfo": "SESSION_ID_HERE"
}
```

### Step 3: Verify OTP (Postman)

**Endpoint:**
```
POST https://identitytoolkit.googleapis.com/v1/accounts:signInWithPhoneNumber?key=YOUR_WEB_API_KEY
```

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "sessionInfo": "SESSION_ID_FROM_STEP_2",
  "code": "123456"
}
```

**Response (Success):**
```json
{
  "idToken": "FIREBASE_ID_TOKEN",
  "refreshToken": "REFRESH_TOKEN",
  "expiresIn": "3600",
  "localId": "USER_ID"
}
```

## Method 2: Test with Real Phone Numbers (Requires reCAPTCHA)

For real phone numbers, you need a reCAPTCHA token. This is more complex.

### Alternative: Use Firebase Emulator

For testing without real SMS:

1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Initialize Firebase:
   ```bash
   cd frontend
   firebase init emulators
   ```

3. Start emulator:
   ```bash
   firebase emulators:start
   ```

4. Use emulator endpoint:
   ```
   http://localhost:9099/identitytoolkit.googleapis.com/v1/accounts:sendVerificationCode
   ```

## Postman Collection

### Request 1: Send OTP

```
POST https://identitytoolkit.googleapis.com/v1/accounts:sendVerificationCode?key={{WEB_API_KEY}}

Headers:
Content-Type: application/json

Body:
{
  "phoneNumber": "+16505551234",
  "recaptchaToken": "test"
}
```

### Request 2: Verify OTP

```
POST https://identitytoolkit.googleapis.com/v1/accounts:signInWithPhoneNumber?key={{WEB_API_KEY}}

Headers:
Content-Type: application/json

Body:
{
  "sessionInfo": "{{SESSION_INFO}}",
  "code": "123456"
}
```

## cURL Examples

### Send OTP:
```bash
curl -X POST \
  'https://identitytoolkit.googleapis.com/v1/accounts:sendVerificationCode?key=YOUR_WEB_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "phoneNumber": "+16505551234",
    "recaptchaToken": "test"
  }'
```

### Verify OTP:
```bash
curl -X POST \
  'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPhoneNumber?key=YOUR_WEB_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "sessionInfo": "SESSION_ID_HERE",
    "code": "123456"
  }'
```

## Testing Script

Create `test_firebase_auth.sh`:

```bash
#!/bin/bash

# Configuration
WEB_API_KEY="YOUR_WEB_API_KEY"
PHONE_NUMBER="+16505551234"
TEST_CODE="123456"

echo "🔥 Testing Firebase Phone Authentication"
echo ""

# Step 1: Send OTP
echo "1️⃣ Sending OTP to $PHONE_NUMBER..."
RESPONSE=$(curl -s -X POST \
  "https://identitytoolkit.googleapis.com/v1/accounts:sendVerificationCode?key=$WEB_API_KEY" \
  -H 'Content-Type: application/json' \
  -d "{
    \"phoneNumber\": \"$PHONE_NUMBER\",
    \"recaptchaToken\": \"test\"
  }")

echo "Response: $RESPONSE"
echo ""

# Extract sessionInfo
SESSION_INFO=$(echo $RESPONSE | grep -o '"sessionInfo":"[^"]*' | cut -d'"' -f4)

if [ -z "$SESSION_INFO" ]; then
    echo "❌ Failed to send OTP"
    echo "Response: $RESPONSE"
    exit 1
fi

echo "✅ OTP sent successfully"
echo "Session Info: $SESSION_INFO"
echo ""

# Step 2: Verify OTP
echo "2️⃣ Verifying OTP code: $TEST_CODE..."
VERIFY_RESPONSE=$(curl -s -X POST \
  "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPhoneNumber?key=$WEB_API_KEY" \
  -H 'Content-Type: application/json' \
  -d "{
    \"sessionInfo\": \"$SESSION_INFO\",
    \"code\": \"$TEST_CODE\"
  }")

echo "Response: $VERIFY_RESPONSE"
echo ""

# Check if successful
if echo "$VERIFY_RESPONSE" | grep -q "idToken"; then
    echo "✅ OTP verified successfully!"
    echo "User authenticated!"
else
    echo "❌ OTP verification failed"
fi
```

Make it executable:
```bash
chmod +x test_firebase_auth.sh
```

Run it:
```bash
./test_firebase_auth.sh
```

## Common Errors

### Error: "INVALID_PHONE_NUMBER"
**Cause:** Phone number format incorrect  
**Fix:** Use E.164 format: `+[country code][number]`  
Example: `+16505551234` (not `650-555-1234`)

### Error: "CAPTCHA_CHECK_FAILED"
**Cause:** Using real phone number without valid reCAPTCHA  
**Fix:** Use test phone numbers instead

### Error: "PHONE_AUTH_NOT_ENABLED"
**Cause:** Phone authentication not enabled in Firebase  
**Fix:** Enable in Firebase Console → Authentication → Sign-in method → Phone

### Error: "INVALID_SESSION_INFO"
**Cause:** Session expired or invalid  
**Fix:** Send OTP again to get new session

### Error: "INVALID_CODE"
**Cause:** Wrong OTP code  
**Fix:** Use correct test code (123456) or real SMS code

## Verify Firebase Configuration

Before testing, verify:

```bash
# Check if Phone Auth is enabled
curl -s "https://identitytoolkit.googleapis.com/v1/projects/private-sambad/config?key=YOUR_WEB_API_KEY" | grep -i phone
```

## Testing Checklist

- [ ] Web API Key obtained from Firebase Console
- [ ] Phone Authentication enabled
- [ ] Test phone numbers added (+1 650-555-1234 → 123456)
- [ ] Postman collection created
- [ ] Send OTP request works
- [ ] Verify OTP request works
- [ ] Received idToken successfully

## Integration with Your App

Once you verify Firebase works via Postman, the issue in your app is likely:

1. **Bundle ID mismatch** - iOS app Bundle ID doesn't match Firebase
2. **Missing REVERSED_CLIENT_ID** - URL scheme not configured
3. **APNs not configured** - Required for real phone numbers on iOS

But test phone numbers should work without APNs!

## Quick Test

1. **Get your Web API Key:**
   ```
   Firebase Console → Project Settings → Web API Key
   ```

2. **Test in Postman:**
   ```
   POST https://identitytoolkit.googleapis.com/v1/accounts:sendVerificationCode?key=YOUR_KEY
   
   Body:
   {
     "phoneNumber": "+16505551234",
     "recaptchaToken": "test"
   }
   ```

3. **If this works:** Firebase is configured correctly, issue is in iOS app
4. **If this fails:** Firebase Phone Auth not enabled or test numbers not added

## Resources

- [Firebase Auth REST API](https://firebase.google.com/docs/reference/rest/auth)
- [Phone Auth API Reference](https://firebase.google.com/docs/reference/rest/auth#section-verify-phone-number)

---

**Your Web API Key:** Check Firebase Console → Project Settings  
**Test Phone:** `+1 650-555-1234`  
**Test Code:** `123456`
