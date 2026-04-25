# App Name Changed

## Issue
"Private Sambad" was already taken in the App Store.

## Solution
Changed app name to **"Sambad Secure"**

## Files Updated

1. ✅ `frontend/ios/Runner/Info.plist`
   - CFBundleDisplayName: "Sambad Secure"
   - CFBundleName: "Sambad Secure"

2. ✅ `frontend/lib/main.dart`
   - MaterialApp title: "Sambad Secure"

## Next Steps

### Option 1: Use "Sambad Secure"

If you like this name:
```bash
cd frontend
flutter clean
flutter pub get
./build_ipa.sh
```

Then upload to App Store Connect.

### Option 2: Choose Different Name

If you want a different name:

1. **Check availability first:**
   - Go to: https://appstoreconnect.apple.com/
   - Try creating new app with your chosen name
   - If available, proceed to step 2

2. **Update the name:**
   ```bash
   cd frontend/ios/Runner
   # Edit Info.plist and change both:
   # - CFBundleDisplayName
   # - CFBundleName
   ```

3. **Update main.dart:**
   ```bash
   cd frontend/lib
   # Edit main.dart and change:
   # title: 'Your New Name'
   ```

4. **Rebuild:**
   ```bash
   cd frontend
   flutter clean
   flutter pub get
   ./build_ipa.sh
   ```

## Alternative Name Suggestions

If "Sambad Secure" is also taken, try:

1. **Sambad Messenger**
2. **Sambad Chat**
3. **Sambad Pro**
4. **Sambad Plus**
5. **Sambad Connect**
6. **Sambad Encrypted**
7. **My Sambad**
8. **Sambad Private Messenger**
9. **Sambad Secure Chat**
10. **Sambad Safe**

## Verification

After rebuilding, verify the name:

```bash
# Run on simulator
cd frontend
flutter run
```

Check:
- [ ] Home screen shows "Sambad Secure"
- [ ] App switcher shows "Sambad Secure"
- [ ] About screen shows correct name

## Current Status

✅ App name changed to "Sambad Secure"  
✅ All files updated  
⏭️ Ready to rebuild IPA  
⏭️ Ready to upload to App Store

## Quick Rebuild

```bash
cd frontend
./build_ipa.sh
```

This will create a new IPA with the name "Sambad Secure".

---

**Note:** Always check name availability in App Store Connect before finalizing your choice!
