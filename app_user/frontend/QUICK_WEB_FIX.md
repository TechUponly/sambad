# 🌐 Web Phone Auth - Quick Fix

## Current Status

✅ **Fixed:**
- Added reCAPTCHA container to web/index.html
- Updated login_screen.dart for web compatibility
- Updated app title to "Sambad Secure"

❌ **Still Broken:**
- Using Android App ID for web (causes 400 error)

## The Problem

```
Error: 400 Bad Request
identitytoolkit.googleapis.com/v1/accounts:sendVerificationCode
```

**Root Cause:** Web app is using Android app ID instead of a proper web app ID.

## The Fix (5 Minutes)

### Step 1: Add Web App in Firebase

1. Open: https://console.firebase.google.com/project/private-sambad/settings/general

2. Scroll to "Your apps"

3. Click "Add app" → Web icon (</>) 

4. Enter nickname: "Sambad Web"

5. Click "Register app"

6. Copy the `appId` (format: `1:1046904512204:web:xxxxxxxxxxxxx`)

### Step 2: Update firebase_options.dart

Open `frontend/lib/firebase_options.dart` and replace:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyB7d8mR41AEaMWpQ308YujKZD2HHWGy89o',
  appId: '1:1046904512204:web:YOUR_ACTUAL_WEB_APP_ID', // ← Paste here
  messagingSenderId: '1046904512204',
  projectId: 'private-sambad',
  storageBucket: 'private-sambad.firebasestorage.app',
  authDomain: 'private-sambad.firebaseapp.com',
);
```

### Step 3: Verify Settings in Firebase Console

**Check 1: Phone Auth Enabled**
- Go to: https://console.firebase.google.com/project/private-sambad/authentication/providers
- Click "Phone"
- Make sure toggle is ON

**Check 2: Authorized Domains**
- Go to: https://console.firebase.google.com/project/private-sambad/authentication/settings
- Make sure `localhost` is in the list
- If not, click "Add domain" and add `localhost`

**Check 3: Test Phone Number**
- In Phone provider settings
- Add test number: +917045249564 → Code: 123456

### Step 4: Test

```bash
cd frontend
flutter run -d chrome
```

1. Enter phone: +917045249564
2. Click "Send OTP"
3. Complete reCAPTCHA
4. Enter OTP: 123456
5. Should log in ✅

## Quick Check

Run this to verify your configuration:

```bash
cd frontend
./check_firebase_web.sh
```

## Files Modified

1. `web/index.html` - Added reCAPTCHA container
2. `lib/screens/login_screen.dart` - Web compatibility
3. `lib/firebase_options.dart` - Needs web app ID update

## Summary

The code is ready. You just need to:
1. Add web app in Firebase Console (2 min)
2. Update the app ID in firebase_options.dart (1 min)
3. Verify settings (2 min)
4. Test (1 min)

Total time: 5 minutes

---

**See WEB_PHONE_AUTH_FIXED.md for detailed troubleshooting**
