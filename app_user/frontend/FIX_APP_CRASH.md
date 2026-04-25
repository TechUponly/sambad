# Fix App Crash After Clicking OTP

## Problem
App closes/crashes immediately after clicking "Send OTP" button.

## Root Cause
This is caused by Firebase Phone Authentication not being properly configured for your Bundle ID `com.shamrai.sambad`.

## Solution

### Step 1: Update Firebase Console

1. **Go to Firebase Console:**
   https://console.firebase.google.com/project/private-sambad/settings/general

2. **Check iOS App Configuration:**
   - Look for iOS app with Bundle ID: `com.shamrai.sambad`
   - If it doesn't exist, you need to add it

3. **Add iOS App (if needed):**
   - Click "Add app" → iOS
   - Enter Bundle ID: `com.shamrai.sambad`
   - App nickname: "Sambad iOS"
   - Register app
   - Download GoogleService-Info.plist
   - Replace `frontend/ios/Runner/GoogleService-Info.plist`

4. **Enable Phone Authentication:**
   - Go to: https://console.firebase.google.com/project/private-sambad/authentication/providers
   - Click "Phone"
   - Toggle "Enable"
   - Click "Save"

5. **Add Test Phone Numbers:**
   - Scroll to "Phone numbers for testing"
   - Add:
     ```
     Phone: +1 650-555-1234
     Code: 123456
     ```
   - Click "Save"

### Step 2: Get Real GoogleService-Info.plist

The current GoogleService-Info.plist has placeholder values. You need the real one:

1. Firebase Console → Project Settings → Your iOS app
2. Download GoogleService-Info.plist
3. Replace: `frontend/ios/Runner/GoogleService-Info.plist`

### Step 3: Update Info.plist with REVERSED_CLIENT_ID

After getting the real GoogleService-Info.plist:

1. Extract REVERSED_CLIENT_ID:
   ```bash
   cd frontend/ios/Runner
   plutil -extract REVERSED_CLIENT_ID raw GoogleService-Info.plist
   ```

2. Copy the output (looks like: `com.googleusercontent.apps.XXXXXXXXX-YYYYYYYY`)

3. Update `frontend/ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLSchemes</key>
   <array>
       <string>PASTE_YOUR_REVERSED_CLIENT_ID_HERE</string>
   </array>
   ```

### Step 4: Clean and Rebuild

```bash
cd frontend
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter run
```

## Quick Test

After completing the steps above:

1. Run the app: `flutter run`
2. Enter test phone: `+1 650-555-1234`
3. Click "Send OTP"
4. App should NOT crash
5. Enter code: `123456`
6. Should log in successfully

## Alternative: Use Existing Firebase App

If you already have a Firebase iOS app with Bundle ID `com.sambad.messenger`:

**Option A: Change Bundle ID to match Firebase**
```bash
# Update Xcode project
cd frontend/ios/Runner.xcodeproj
sed -i '' 's/com.shamrai.sambad/com.sambad.messenger/g' project.pbxproj

# Update GoogleService-Info.plist
cd ../Runner
sed -i '' 's/com.shamrai.sambad/com.sambad.messenger/g' GoogleService-Info.plist
```

**Option B: Add new iOS app in Firebase with com.shamrai.sambad**
(Recommended - see Step 1 above)

## Debug the Crash

To see the exact error:

1. **Open in Xcode:**
   ```bash
   open frontend/ios/Runner.xcworkspace
   ```

2. **Run from Xcode** and check console for errors

3. **Common errors:**
   - "No matching client found" → Bundle ID mismatch
   - "reCAPTCHA verification failed" → Missing REVERSED_CLIENT_ID
   - "Phone authentication not enabled" → Enable in Firebase Console
   - "Missing APNs token" → Use test phone numbers instead

## Verification Checklist

- [ ] Bundle ID in Xcode: `com.shamrai.sambad`
- [ ] Bundle ID in GoogleService-Info.plist: `com.shamrai.sambad`
- [ ] iOS app exists in Firebase Console with this Bundle ID
- [ ] Phone Authentication enabled in Firebase Console
- [ ] Test phone numbers added
- [ ] Real GoogleService-Info.plist downloaded and replaced
- [ ] REVERSED_CLIENT_ID added to Info.plist
- [ ] App rebuilt after changes

## Current Status

✅ Bundle ID changed back to `com.shamrai.sambad`  
⚠️ Need to configure Firebase for this Bundle ID  
⚠️ Need real GoogleService-Info.plist  
⚠️ Need to enable Phone Authentication  

## Next Steps

1. Go to Firebase Console
2. Add iOS app with Bundle ID `com.shamrai.sambad` (or verify it exists)
3. Download GoogleService-Info.plist
4. Replace the file
5. Enable Phone Authentication
6. Add test phone numbers
7. Rebuild and test

---

**Firebase Console:**  
https://console.firebase.google.com/project/private-sambad/settings/general
