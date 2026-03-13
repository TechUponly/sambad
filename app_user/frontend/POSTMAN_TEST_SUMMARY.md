# Test Firebase Phone Auth with Postman - Quick Guide

## What You Need

1. **Firebase Web API Key:** `AIzaSyB7d8mR41AEaMWpQ308YujKZD2HHWGy89o`
2. **Test Phone Number:** `+1 650-555-1234`
3. **Test OTP Code:** `123456`

## Before Testing

### Enable Phone Auth in Firebase Console:

1. Go to: https://console.firebase.google.com/project/private-sambad/authentication/providers
2. Click "Phone"
3. Toggle "Enable"
4. Add test phone number:
   - Phone: `+1 650-555-1234`
   - Code: `123456`
5. Click "Save"

## Method 1: Use Postman Collection (Easiest)

1. **Import Collection:**
   - Open Postman
   - Click "Import"
   - Select `Firebase_Phone_Auth.postman_collection.json`

2. **Run Requests in Order:**
   - Request 1: "Send OTP (Test Phone)" → Click Send
   - Request 2: "Verify OTP (Test Code)" → Click Send
   - Request 3: "Get User Info" → Click Send

3. **Check Results:**
   - All should return 200 OK
   - Request 2 should return `idToken`

## Method 2: Manual Postman Requests

### Request 1: Send OTP

```
POST https://identitytoolkit.googleapis.com/v1/accounts:sendVerificationCode?key=AIzaSyB7d8mR41AEaMWpQ308YujKZD2HHWGy89o

Headers:
Content-Type: application/json

Body (raw JSON):
{
  "phoneNumber": "+16505551234",
  "recaptchaToken": "test"
}
```

**Expected Response:**
```json
{
  "sessionInfo": "SESSION_ID_HERE"
}
```

Copy the `sessionInfo` value for next request.

### Request 2: Verify OTP

```
POST https://identitytoolkit.googleapis.com/v1/accounts:signInWithPhoneNumber?key=AIzaSyB7d8mR41AEaMWpQ308YujKZD2HHWGy89o

Headers:
Content-Type: application/json

Body (raw JSON):
{
  "sessionInfo": "PASTE_SESSION_INFO_HERE",
  "code": "123456"
}
```

**Expected Response:**
```json
{
  "idToken": "FIREBASE_ID_TOKEN",
  "refreshToken": "REFRESH_TOKEN",
  "expiresIn": "3600",
  "localId": "USER_ID"
}
```

## Method 3: Use Test Script

```bash
cd frontend
./test_firebase_api.sh
```

This will automatically test both steps and show results.

## What This Proves

✅ **If Postman test works:**
- Firebase Phone Authentication is configured correctly
- Test phone numbers are working
- The issue is in your iOS app (Bundle ID, REVERSED_CLIENT_ID, etc.)

❌ **If Postman test fails:**
- Phone Authentication not enabled in Firebase Console
- Test phone numbers not added
- Wrong API key

## Common Errors

### Error: "PHONE_AUTH_NOT_ENABLED"
**Fix:** Enable Phone provider in Firebase Console

### Error: "INVALID_PHONE_NUMBER"
**Fix:** Use E.164 format: `+16505551234` (not `650-555-1234`)

### Error: "CAPTCHA_CHECK_FAILED"
**Fix:** Use test phone numbers (not real numbers)

### Error: "INVALID_CODE"
**Fix:** Use test code `123456` for test phone number

## Next Steps After Postman Test

### If Postman Works ✅

The issue is in your iOS app. Fix:

1. **Add iOS app in Firebase:**
   - Bundle ID: `com.shamrai.sambad`
   - Download GoogleService-Info.plist
   - Replace in `frontend/ios/Runner/`

2. **Update REVERSED_CLIENT_ID:**
   - Extract from GoogleService-Info.plist
   - Add to Info.plist CFBundleURLSchemes

3. **Rebuild:**
   ```bash
   cd frontend
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..
   flutter run
   ```

### If Postman Fails ❌

Fix Firebase configuration:

1. Enable Phone Authentication
2. Add test phone numbers
3. Verify API key is correct
4. Try again

## Files Created

1. **Firebase_Phone_Auth.postman_collection.json** - Import into Postman
2. **test_firebase_api.sh** - Automated test script
3. **TEST_FIREBASE_POSTMAN.md** - Detailed guide

## Quick Test Checklist

- [ ] Phone Authentication enabled in Firebase Console
- [ ] Test phone number added (+1 650-555-1234 → 123456)
- [ ] Postman collection imported
- [ ] Request 1 (Send OTP) returns sessionInfo
- [ ] Request 2 (Verify OTP) returns idToken
- [ ] Test script runs successfully

## Firebase Console Links

- **Enable Phone Auth:** https://console.firebase.google.com/project/private-sambad/authentication/providers
- **Add Test Numbers:** Same link, scroll down after enabling
- **Get API Key:** https://console.firebase.google.com/project/private-sambad/settings/general

---

**Your API Key:** `AIzaSyB7d8mR41AEaMWpQ308YujKZD2HHWGy89o`  
**Test Phone:** `+1 650-555-1234`  
**Test Code:** `123456`

**Start Here:** Import `Firebase_Phone_Auth.postman_collection.json` into Postman
