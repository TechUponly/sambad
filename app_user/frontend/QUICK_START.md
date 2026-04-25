# 🚀 Quick Start: Fix OTP Crash

## What You Need to Know

✅ Firebase Phone Auth is working (proven by your Postman test)  
✅ You got valid tokens for +917045249564  
❌ iOS app crashes because it has placeholder Firebase config

## Fix in 3 Commands

### 1. Download Real Firebase Config

Go to: https://console.firebase.google.com/project/private-sambad/settings/general

- If you see iOS app with Bundle ID `com.shamrai.sambad`: Download GoogleService-Info.plist
- If you don't see it: Add iOS app → Bundle ID: `com.shamrai.sambad` → Download file

Save it to your Downloads folder.

### 2. Replace and Update

```bash
cd ~/Downloads/app_user/frontend

# Replace the placeholder file
cp ~/Downloads/GoogleService-Info.plist ios/Runner/

# Update URL Scheme automatically
./update_url_scheme.sh

# Verify everything is correct
./verify_firebase_config.sh
```

### 3. Rebuild and Run

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

## Test It

1. Enter: +917045249564
2. Click "Send OTP" ✅ No crash!
3. Enter: 123456
4. ✅ Logged in!

## That's It!

The whole process takes 5 minutes. Your Postman test proved Firebase works perfectly - the app just needs the right credentials.

## Troubleshooting

If something goes wrong:

```bash
# Check what's wrong
./verify_firebase_config.sh

# It will tell you exactly what to fix
```

## Files You Need

1. `GoogleService-Info.plist` from Firebase Console
2. That's it!

## Scripts Available

- `verify_firebase_config.sh` - Check if config is correct
- `update_url_scheme.sh` - Auto-update URL scheme
- `test_firebase_api.sh` - Test Firebase API (already working)

## More Details

- `NEXT_STEPS.md` - Step-by-step guide
- `ACTION_REQUIRED.md` - Detailed instructions
- `STATUS_SUMMARY.md` - Complete project status

---

**TL;DR:** Download real GoogleService-Info.plist from Firebase Console, replace the file, run 3 commands, done.
