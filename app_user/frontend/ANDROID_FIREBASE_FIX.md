# Android Firebase Phone Auth Fix

## Issue
The Android APK was not working because the Firebase configuration had the wrong package name.

## What Was Fixed
1. Updated `android/app/google-services.json` package name from `com.example.my_first_flutter_app` to `com.sambad.messenger`

## Additional Setup Required in Firebase Console

To make Phone Authentication work on Android, you need to add the SHA-1 fingerprint to Firebase:

### Your Debug SHA-1 Fingerprint:
```
38:F5:F5:77:57:1E:08:7E:C0:28:8F:0B:AE:0B:DA:61:0D:D1:08:F8
```

### Steps to Add SHA-1 to Firebase:

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project: "private-sambad"
3. Click on Project Settings (gear icon)
4. Scroll down to "Your apps" section
5. Find the Android app (com.sambad.messenger)
6. Click "Add fingerprint"
7. Paste the SHA-1: `38:F5:F5:77:57:1E:08:7E:C0:28:8F:0B:AE:0B:DA:61:0D:D1:08:F8`
8. Click "Save"
9. Download the updated `google-services.json` file
10. Replace `android/app/google-services.json` with the new file

### For Production Release:

When you create a release keystore for Google Play Store, you'll need to:

1. Generate release keystore:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Get the SHA-1 from release keystore:
```bash
keytool -list -v -keystore ~/upload-keystore.jks -alias upload
```

3. Add that SHA-1 to Firebase Console as well

## Rebuild APK

After updating the Firebase configuration:

```bash
cd frontend
flutter clean
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## Testing

1. Install the APK on an Android device
2. Try phone authentication
3. It should now work properly with Firebase

## Note

The current APK is signed with the debug keystore. For production:
- Create a proper release keystore
- Update `android/app/build.gradle.kts` with release signing config
- Add release SHA-1 to Firebase
- Build with release signing
