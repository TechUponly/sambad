# Production Signing Information

## Production Keystore Created

**Keystore Location:** `~/upload-keystore.jks`

**Keystore Credentials:**
- Store Password: `sambad123`
- Key Password: `sambad123`
- Key Alias: `upload`

**Production SHA-1 Fingerprint:**
```
AB:41:17:C7:8C:39:47:D5:33:A9:97:68:D0:40:1B:EE:16:D8:8B:B3
```

## Built Files

**APK (Direct Installation):**
- Location: `build/app/outputs/flutter-apk/app-release.apk`
- Size: 53.2 MB
- Signed with: Production keystore

**AAB (Google Play Store):**
- Location: `build/app/outputs/bundle/release/app-release.aab`
- Size: 44.9 MB
- Signed with: Production keystore

## App Information

- **Package Name:** com.sambad.messenger
- **Version:** 4.0.9 (Build 5)
- **App Name:** Private Sambad

## Firebase Setup Required

**IMPORTANT:** Add the production SHA-1 fingerprint to Firebase Console:

1. Go to Firebase Console → Project Settings
2. Find Android app (com.sambad.messenger)
3. Add SHA-1: `AB:41:17:C7:8C:39:47:D5:33:A9:97:68:D0:40:1B:EE:16:D8:8B:B3`
4. Download updated `google-services.json`
5. Replace current file and rebuild

## Google Play Store Upload

Use the AAB file for Google Play Console:
1. Go to Google Play Console
2. Create new app or select existing
3. Upload `app-release.aab`
4. Complete store listing
5. Submit for review

## Security Notes

- Keep `~/upload-keystore.jks` secure and backed up
- Never share keystore passwords
- Use the same keystore for all future updates
- Store credentials securely (password manager recommended)

## Commands Used

```bash
# Create keystore
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload -storepass sambad123 -keypass sambad123 -dname "CN=Private Sambad, OU=Development, O=Sambad Inc, L=City, S=State, C=US"

# Build AAB
flutter build appbundle --release

# Build APK
flutter build apk --release

# Get SHA-1
keytool -list -v -keystore ~/upload-keystore.jks -alias upload -storepass sambad123 -keypass sambad123
```