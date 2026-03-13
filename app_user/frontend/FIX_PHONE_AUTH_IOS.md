# Fix iOS Phone Authentication

## Problem
Firebase Phone Authentication on iOS requires additional configuration that's missing from your current setup.

## Solution

### Step 1: Download Complete GoogleService-Info.plist

Your current `GoogleService-Info.plist` is missing the `REVERSED_CLIENT_ID` field which is required for phone authentication.

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **private-sambad**
3. Go to Project Settings (gear icon)
4. Scroll down to "Your apps" section
5. Find your iOS app (Bundle ID: `com.sambad.messenger`)
6. Click "Download GoogleService-Info.plist"
7. Replace the existing file at `frontend/ios/Runner/GoogleService-Info.plist`

### Step 2: Update Info.plist with URL Scheme

After downloading the new GoogleService-Info.plist:

1. Open the new `GoogleService-Info.plist`
2. Find the `REVERSED_CLIENT_ID` value (looks like: `com.googleusercontent.apps.XXXXXXXXX`)
3. Update `frontend/ios/Runner/Info.plist` with this URL scheme

I've already added the URL scheme structure to Info.plist, but you need to replace the placeholder with the actual REVERSED_CLIENT_ID from your GoogleService-Info.plist.

Look for this section in Info.plist:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.1046904512204-qlqvvvvvvvvvvvvvvvvvvvvvvvvvvvvv</string>
        </array>
    </dict>
</array>
```

Replace the placeholder string with your actual REVERSED_CLIENT_ID.

### Step 3: Enable Phone Authentication in Firebase Console

1. Go to Firebase Console → Authentication
2. Click "Sign-in method" tab
3. Enable "Phone" provider
4. Add your app's App Store ID (or leave blank for testing)
5. Save

### Step 4: Configure APNs (Apple Push Notification service)

Phone authentication on iOS requires APNs:

#### Option A: For Testing (Easier)
1. In Firebase Console → Project Settings → Cloud Messaging
2. Under "Apple app configuration"
3. Upload your APNs Authentication Key or Certificate
4. For development, you can use a development certificate

#### Option B: For Production
1. Get an APNs Authentication Key from Apple Developer Portal
2. Upload to Firebase Console

### Step 5: Update AppDelegate (if needed)

Check if `frontend/ios/Runner/AppDelegate.swift` exists and has Firebase initialization:

```swift
import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Step 6: Rebuild

```bash
cd frontend

# Clean everything
flutter clean
rm -rf ios/Pods ios/Podfile.lock

# Reinstall
flutter pub get
cd ios
pod install
cd ..

# Build
flutter build ios --debug
```

### Step 7: Test

```bash
flutter run
```

## Alternative: Use Test Phone Numbers (For Development)

If you want to test without setting up APNs:

1. Go to Firebase Console → Authentication → Sign-in method
2. Scroll down to "Phone numbers for testing"
3. Add test phone numbers with verification codes
4. Example:
   - Phone: +1 650-555-1234
   - Code: 123456

Then in your app, use these test numbers and they'll work without SMS.

## Common Issues

### Issue: "reCAPTCHA verification failed"
**Solution:** Make sure URL scheme is correctly configured in Info.plist

### Issue: "Missing APNs token"
**Solution:** Configure APNs in Firebase Console or use test phone numbers

### Issue: "Invalid phone number"
**Solution:** Make sure to include country code (e.g., +91 for India)

### Issue: Still getting errors
**Solution:** Check Xcode console for detailed error messages:
```bash
open ios/Runner.xcworkspace
```
Then run from Xcode and check the console output.

## Quick Test Command

```bash
# Run with verbose logging
flutter run --verbose
```

## Verification Checklist

- [ ] Downloaded fresh GoogleService-Info.plist from Firebase
- [ ] REVERSED_CLIENT_ID exists in GoogleService-Info.plist
- [ ] URL scheme added to Info.plist with correct REVERSED_CLIENT_ID
- [ ] Phone authentication enabled in Firebase Console
- [ ] APNs configured OR test phone numbers added
- [ ] Pods reinstalled
- [ ] App rebuilt and tested

## Need Help?

If you're still having issues, share:
1. The exact error message from Xcode console
2. Your Firebase project settings (screenshot)
3. Contents of your GoogleService-Info.plist (remove sensitive keys)
