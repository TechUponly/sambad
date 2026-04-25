# Complete iOS Setup Guide

## Critical Issues Found

### 1. Bundle ID Mismatch
- **Xcode Project:** `com.shamrai.sambad`
- **Firebase Config:** `com.sambad.messenger`

### 2. Missing REVERSED_CLIENT_ID
Your GoogleService-Info.plist is incomplete and missing the REVERSED_CLIENT_ID required for phone authentication.

## Solution: Reconfigure Firebase iOS App

### Step 1: Go to Firebase Console

1. Open: https://console.firebase.google.com/
2. Select project: **private-sambad**
3. Click the gear icon → **Project Settings**

### Step 2: Check Your iOS App Configuration

In the "Your apps" section, you should see an iOS app. Check its Bundle ID.

#### Option A: Bundle ID is `com.shamrai.sambad`
If the Firebase iOS app already has Bundle ID `com.shamrai.sambad`:
1. Download the GoogleService-Info.plist
2. Replace `frontend/ios/Runner/GoogleService-Info.plist`
3. Skip to Step 4

#### Option B: Bundle ID is `com.sambad.messenger` (Current)
You need to either:
- **Option B1:** Update Xcode to use `com.sambad.messenger`
- **Option B2:** Create a new iOS app in Firebase with `com.shamrai.sambad`

### Step 3A: Update Xcode Bundle ID (Recommended)

1. Open Xcode:
   ```bash
   open frontend/ios/Runner.xcworkspace
   ```

2. Select **Runner** project in the navigator
3. Select **Runner** target
4. Go to **Signing & Capabilities** tab
5. Change **Bundle Identifier** to: `com.sambad.messenger`
6. Select your development team
7. Save (Cmd+S)

### Step 3B: OR Create New Firebase iOS App

1. In Firebase Console → Project Settings
2. Click "Add app" → iOS
3. Enter Bundle ID: `com.shamrai.sambad`
4. Register app
5. Download GoogleService-Info.plist
6. Replace `frontend/ios/Runner/GoogleService-Info.plist`

### Step 4: Download Complete GoogleService-Info.plist

After ensuring Bundle IDs match:

1. In Firebase Console → Project Settings → Your apps
2. Find your iOS app
3. Click the download icon (⬇️) to download GoogleService-Info.plist
4. **Important:** This new file will include REVERSED_CLIENT_ID
5. Replace: `frontend/ios/Runner/GoogleService-Info.plist`

### Step 5: Extract and Configure URL Scheme

1. Open the new GoogleService-Info.plist
2. Find this key:
   ```xml
   <key>REVERSED_CLIENT_ID</key>
   <string>com.googleusercontent.apps.XXXXXXXXX-YYYYYYYY</string>
   ```
3. Copy the string value

4. Open `frontend/ios/Runner/Info.plist`
5. Find the CFBundleURLSchemes section
6. Replace the placeholder with your REVERSED_CLIENT_ID:
   ```xml
   <key>CFBundleURLSchemes</key>
   <array>
       <string>com.googleusercontent.apps.XXXXXXXXX-YYYYYYYY</string>
   </array>
   ```

### Step 6: Enable Phone Authentication in Firebase

1. Firebase Console → **Authentication**
2. Click **Sign-in method** tab
3. Click **Phone** provider
4. Toggle **Enable**
5. Click **Save**

### Step 7: Configure for Testing (Choose One)

#### Option A: Use Test Phone Numbers (Easiest for Development)

1. In Authentication → Sign-in method
2. Scroll to "Phone numbers for testing"
3. Click "Add phone number"
4. Add test numbers:
   - Phone: `+1 650-555-1234` → Code: `123456`
   - Phone: `+91 9876543210` → Code: `123456`
5. Save

Now you can test without SMS or APNs!

#### Option B: Configure APNs (For Real SMS)

1. Get APNs Authentication Key from Apple Developer Portal
2. Firebase Console → Project Settings → Cloud Messaging
3. Under "Apple app configuration"
4. Upload APNs Auth Key
5. Enter Key ID and Team ID

### Step 8: Clean and Rebuild

```bash
cd frontend

# Clean everything
flutter clean
rm -rf ios/Pods ios/Podfile.lock ios/.symlinks

# Get dependencies
flutter pub get

# Install pods
cd ios
pod install
cd ..

# Build
flutter build ios --debug
```

### Step 9: Test

```bash
flutter run
```

Or open in Xcode:
```bash
open ios/Runner.xcworkspace
```

## Quick Verification Checklist

- [ ] Bundle IDs match (Xcode and Firebase)
- [ ] Downloaded fresh GoogleService-Info.plist from Firebase
- [ ] REVERSED_CLIENT_ID exists in GoogleService-Info.plist
- [ ] URL scheme added to Info.plist with correct REVERSED_CLIENT_ID
- [ ] Phone authentication enabled in Firebase Console
- [ ] Test phone numbers added OR APNs configured
- [ ] Pods reinstalled
- [ ] App rebuilt

## Testing the Fix

1. Run the app
2. You should see the login screen (not blank)
3. Enter a test phone number (e.g., +1 650-555-1234)
4. Click "Send OTP"
5. Enter the test code (e.g., 123456)
6. Should successfully log in

## Common Errors and Solutions

### Error: "Unsupported platform"
**Fixed!** We added iOS configuration to firebase_options.dart

### Error: "reCAPTCHA verification failed"
**Cause:** Missing or incorrect URL scheme
**Fix:** Ensure REVERSED_CLIENT_ID is correctly set in Info.plist

### Error: "Missing APNs token"
**Cause:** APNs not configured
**Fix:** Use test phone numbers instead (see Step 7A)

### Error: Bundle ID mismatch
**Cause:** Xcode and Firebase have different Bundle IDs
**Fix:** Make them match (see Step 3)

## Need Help?

If you're still stuck:

1. Check Xcode console for detailed errors:
   ```bash
   open ios/Runner.xcworkspace
   ```
   Then run and check the console output

2. Verify Firebase configuration:
   ```bash
   cat ios/Runner/GoogleService-Info.plist | grep -E "BUNDLE_ID|REVERSED_CLIENT_ID|GOOGLE_APP_ID"
   ```

3. Check Bundle ID in Xcode:
   ```bash
   grep -r "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | head -3
   ```

## Summary

The main issues are:
1. ✅ App name changed to "Private Sambad"
2. ✅ iOS Firebase configuration added
3. ⚠️ Need to download complete GoogleService-Info.plist from Firebase
4. ⚠️ Need to ensure Bundle IDs match
5. ⚠️ Need to add URL scheme with REVERSED_CLIENT_ID
6. ⚠️ Need to enable Phone Auth and add test numbers

Follow the steps above to complete the setup!
