# Quick Fix: iOS Phone Authentication

## The Problem
Firebase Phone Auth on iOS needs a URL scheme that's missing from your GoogleService-Info.plist.

## Quick Fix (3 Steps)

### 1. Download Fresh Config from Firebase

```
Firebase Console → Project Settings → iOS App → Download GoogleService-Info.plist
```

Replace: `frontend/ios/Runner/GoogleService-Info.plist`

### 2. Get the REVERSED_CLIENT_ID

Open the new GoogleService-Info.plist and find:
```xml
<key>REVERSED_CLIENT_ID</key>
<string>com.googleusercontent.apps.XXXXXXXXX-YYYYYYYY</string>
```

Copy that string value.

### 3. Update Info.plist

In `frontend/ios/Runner/Info.plist`, find the CFBundleURLSchemes section and replace the placeholder with your REVERSED_CLIENT_ID:

```xml
<key>CFBundleURLSchemes</key>
<array>
    <string>YOUR_REVERSED_CLIENT_ID_HERE</string>
</array>
```

### 4. Rebuild

```bash
cd frontend
./fix_ios_phone_auth.sh
```

Or manually:
```bash
cd frontend
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

## For Testing Without SMS

Add test phone numbers in Firebase Console:

```
Firebase Console → Authentication → Sign-in method → Phone numbers for testing
```

Example:
- Phone: `+1 650-555-1234`
- Code: `123456`

Then use these in your app - no SMS required!

## Still Not Working?

See detailed guide: `FIX_PHONE_AUTH_IOS.md`
