# Fix Web Phone Authentication 400 Error

## The Problem

Getting 400 error when trying to send OTP on web:
```
Failed to load resource: the server responded with a status of 400
identitytoolkit.googleapis.com/v1/accounts:sendVerificationCode
```

## Root Cause

Phone Authentication on web requires:
1. Phone Auth to be enabled in Firebase Console
2. Authorized domains to be configured
3. A proper web app to be registered

## Solution

### Step 1: Enable Phone Authentication

1. Go to: https://console.firebase.google.com/project/private-sambad/authentication/providers

2. Click on "Phone" provider

3. Make sure it's **Enabled** (toggle should be ON)

4. Click "Save"

### Step 2: Add Authorized Domain

1. Go to: https://console.firebase.google.com/project/private-sambad/authentication/settings

2. Scroll to "Authorized domains"

3. Click "Add domain"

4. Add: `localhost`

5. Click "Add"

### Step 3: Add Web App (Recommended)

Currently using Android app ID for web. This might cause issues.

1. Go to: https://console.firebase.google.com/project/private-sambad/settings/general

2. Scroll to "Your apps"

3. Click "Add app" → Web icon (</>)

4. Enter:
   - App nickname: "Sambad Web"
   - Check "Also set up Firebase Hosting" (optional)

5. Click "Register app"

6. Copy the `appId` from the config (looks like: `1:1046904512204:web:xxxxx`)

7. Update `frontend/lib/firebase_options.dart`:
   ```dart
   static const FirebaseOptions web = FirebaseOptions(
     apiKey: 'AIzaSyB7d8mR41AEaMWpQ308YujKZD2HHWGy89o',
     appId: '1:1046904512204:web:YOUR_ACTUAL_WEB_APP_ID', // Replace this
     messagingSenderId: '1046904512204',
     projectId: 'private-sambad',
     storageBucket: 'private-sambad.firebasestorage.app',
     authDomain: 'private-sambad.firebaseapp.com',
   );
   ```

8. Hot reload the app (press `r` in terminal)

### Step 4: Add Test Phone Number

1. Go to: https://console.firebase.google.com/project/private-sambad/authentication/providers

2. Click "Phone"

3. Scroll to "Phone numbers for testing"

4. Click "Add phone number"

5. Add:
   - Phone: +917045249564
   - Code: 123456

6. Click "Add"

## Quick Fix (Try This First)

The most common issue is missing authorized domain. Try this:

1. Go to: https://console.firebase.google.com/project/private-sambad/authentication/settings

2. Under "Authorized domains", make sure `localhost` is listed

3. If not, add it

4. Refresh your browser and try again

## Alternative: Test with Real Domain

If localhost doesn't work, you can:

1. Deploy to Firebase Hosting (free)
2. Or use ngrok to get a public URL
3. Add that domain to authorized domains

## Check Current Settings

To verify your settings:

1. **Phone Auth Enabled?**
   - https://console.firebase.google.com/project/private-sambad/authentication/providers
   - Phone should show "Enabled"

2. **Authorized Domains?**
   - https://console.firebase.google.com/project/private-sambad/authentication/settings
   - Should include: localhost, private-sambad.firebaseapp.com

3. **Test Numbers Added?**
   - In Phone provider settings
   - Should have +917045249564 with code 123456

## Expected Result

After fixing:
1. Enter phone: +917045249564
2. Click "Send OTP"
3. reCAPTCHA appears (checkbox or challenge)
4. Complete reCAPTCHA
5. OTP sent successfully
6. Enter: 123456
7. Logged in!

## Still Not Working?

Check browser console for the exact error message. Common errors:

- **"auth/invalid-app-credential"** → Need to add web app in Firebase
- **"auth/unauthorized-domain"** → Add localhost to authorized domains
- **"auth/operation-not-allowed"** → Enable Phone Auth in Firebase Console
- **"auth/captcha-check-failed"** → reCAPTCHA issue, try refreshing

## Debug Info

Current configuration:
- API Key: AIzaSyB7d8mR41AEaMWpQ308YujKZD2HHWGy89o
- Project: private-sambad
- Using: Android app ID (temporary)
- Domain: localhost:59708

---

**Most likely fix:** Add `localhost` to authorized domains in Firebase Console.
