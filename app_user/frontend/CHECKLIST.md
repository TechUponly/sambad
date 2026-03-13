# ✅ OTP Fix Checklist

## Pre-Flight Check

- [x] Firebase Phone Auth tested with Postman ✅
- [x] Received valid tokens for +917045249564 ✅
- [x] Bundle ID is `com.shamrai.sambad` ✅
- [x] App name is "Sambad Secure" ✅
- [ ] Real GoogleService-Info.plist downloaded ⚠️
- [ ] URL Scheme updated ⚠️
- [ ] App rebuilt ⚠️

## Step-by-Step Checklist

### Step 1: Firebase Console
- [ ] Open https://console.firebase.google.com/project/private-sambad/settings/general
- [ ] Check if iOS app exists with Bundle ID `com.shamrai.sambad`
  - [ ] If YES: Click app → Download GoogleService-Info.plist
  - [ ] If NO: Add app → iOS → Bundle ID: `com.shamrai.sambad` → Download
- [ ] File saved to Downloads folder

### Step 2: Replace Configuration
```bash
cd ~/Downloads/app_user/frontend
cp ~/Downloads/GoogleService-Info.plist ios/Runner/
```
- [ ] File copied successfully

### Step 3: Update URL Scheme
```bash
./update_url_scheme.sh
```
- [ ] Script ran successfully
- [ ] Shows "✅ Successfully updated URL Scheme!"

### Step 4: Verify Configuration
```bash
./verify_firebase_config.sh
```
- [ ] Shows "✅ GoogleService-Info.plist looks good!"
- [ ] Shows "✅ Info.plist URL Scheme matches!"
- [ ] Shows "🎉 Configuration looks correct!"

### Step 5: Enable Phone Auth (if needed)
- [ ] Open https://console.firebase.google.com/project/private-sambad/authentication/providers
- [ ] Phone provider is enabled (toggle ON)
- [ ] Test number added: +917045249564 with code 123456

### Step 6: Rebuild App
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
```
- [ ] All commands completed successfully

### Step 7: Run App
```bash
flutter run
```
- [ ] App launches successfully
- [ ] No crash on startup

### Step 8: Test OTP
- [ ] Enter phone: +917045249564
- [ ] Click "Send OTP"
- [ ] App does NOT crash ✅
- [ ] Enter code: 123456
- [ ] Successfully logged in ✅

## Success Criteria

All of these should be true:
- [ ] No placeholder in GoogleService-Info.plist
- [ ] URL Scheme matches REVERSED_CLIENT_ID
- [ ] Phone Auth enabled in Firebase
- [ ] App runs without crash
- [ ] OTP sends successfully
- [ ] Login works

## If Something Fails

### App Still Crashes
```bash
# Check configuration
./verify_firebase_config.sh

# Check Xcode console for errors
open ios/Runner.xcworkspace
# Click Run and check console
```

### Can't Download GoogleService-Info.plist
- Make sure you're logged into Firebase Console
- Make sure you have access to project "private-sambad"
- Try adding a new iOS app if existing one doesn't work

### URL Scheme Update Fails
```bash
# Manual update
REVERSED_ID=$(plutil -extract REVERSED_CLIENT_ID raw ios/Runner/GoogleService-Info.plist)
echo "Use this value: $REVERSED_ID"
# Then edit ios/Runner/Info.plist in Xcode
```

### Build Fails
```bash
# Clean everything
flutter clean
rm -rf ios/Pods
rm ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..
```

## Quick Reference

| File | Status | Action |
|------|--------|--------|
| GoogleService-Info.plist | ⚠️ Placeholder | Download from Firebase |
| Info.plist | ⚠️ Needs update | Run update_url_scheme.sh |
| firebase_options.dart | ✅ Correct | No action needed |
| main.dart | ✅ Fixed | No action needed |

## Time Estimate

- Download config: 2 minutes
- Replace and update: 1 minute
- Rebuild: 2 minutes
- Test: 1 minute

**Total: ~6 minutes**

## Help

If stuck, check these files:
- `QUICK_START.md` - Fastest path
- `NEXT_STEPS.md` - Detailed steps
- `ACTION_REQUIRED.md` - Complete guide
- `STATUS_SUMMARY.md` - Project overview

---

**Current Status:** 95% complete. Just need real Firebase config file.
