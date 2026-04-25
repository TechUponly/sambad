# Add Web App to Firebase

## Current Issue

The web app is using a placeholder App ID:
```
appId: '1:1046904512204:web:YOUR_WEB_APP_ID'
```

This prevents Phone Authentication from working on web.

## Solution: Add Web App in Firebase Console

### Step 1: Add Web App

1. Go to: https://console.firebase.google.com/project/private-sambad/settings/general

2. Scroll to "Your apps" section

3. Click "Add app" → Web icon (</>) 

4. Enter:
   - App nickname: "Sambad Web"
   - Check "Also set up Firebase Hosting" (optional)

5. Click "Register app"

### Step 2: Copy Configuration

You'll see something like:
```javascript
const firebaseConfig = {
  apiKey: "AIzaSyB7d8mR41AEaMWpQ308YujKZD2HHWGy89o",
  authDomain: "private-sambad.firebaseapp.com",
  projectId: "private-sambad",
  storageBucket: "private-sambad.firebasestorage.app",
  messagingSenderId: "1046904512204",
  appId: "1:1046904512204:web:ACTUAL_WEB_APP_ID"
};
```

Copy the `appId` value (the part after `web:`)

### Step 3: Update firebase_options.dart

Replace in `frontend/lib/firebase_options.dart`:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyB7d8mR41AEaMWpQ308YujKZD2HHWGy89o',
  appId: '1:1046904512204:web:PASTE_YOUR_ACTUAL_WEB_APP_ID_HERE',
  messagingSenderId: '1046904512204',
  projectId: 'private-sambad',
  storageBucket: 'private-sambad.firebasestorage.app',
  authDomain: 'private-sambad.firebaseapp.com',
);
```

### Step 4: Hot Reload

In the terminal where Flutter is running, press:
- `r` for hot reload
- Or `R` for hot restart

### Step 5: Enable Phone Auth for Web

1. Go to: https://console.firebase.google.com/project/private-sambad/authentication/providers

2. Click "Phone"

3. Make sure it's enabled

4. Add test phone number:
   - Phone: +917045249564
   - Code: 123456

### Step 6: Test

1. Refresh the Chrome browser
2. Enter phone number: +917045249564
3. Click "Send OTP"
4. Complete reCAPTCHA challenge
5. Enter code: 123456
6. Should log in successfully

## Alternative: Use Android Config Temporarily

If you don't want to create a web app right now, you can temporarily use the Android app ID:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyB7d8mR41AEaMWpQ308YujKZD2HHWGy89o',
  appId: '1:1046904512204:android:646b302f9a7520f112ac69',  // Using Android ID
  messagingSenderId: '1046904512204',
  projectId: 'private-sambad',
  storageBucket: 'private-sambad.firebasestorage.app',
  authDomain: 'private-sambad.firebaseapp.com',
);
```

But this is not recommended for production.

## Current Status

- ✅ App running on Chrome
- ✅ reCAPTCHA initializing
- ❌ Web App ID is placeholder
- ⚠️ Phone Auth won't work until Web App ID is fixed

## Quick Fix

If you just want to test quickly, I can update the code to use the Android app ID temporarily.
