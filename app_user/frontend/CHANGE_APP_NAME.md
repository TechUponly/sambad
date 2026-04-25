# Change App Name Guide

## Problem
"Private Sambad" is already taken in the App Store. You need a unique name.

## Suggested Alternative Names

1. **Sambad Secure**
2. **Sambad Private Messenger**
3. **Sambad Chat**
4. **Sambad Encrypted**
5. **Sambad Pro**
6. **My Sambad**
7. **Sambad Connect**
8. **Sambad Messenger**
9. **Sambad Plus**
10. **Sambad Secure Chat**

## How to Change the App Name

### Step 1: Update Info.plist

Edit `frontend/ios/Runner/Info.plist`:

```xml
<key>CFBundleDisplayName</key>
<string>YOUR_NEW_NAME_HERE</string>
```

For example:
```xml
<key>CFBundleDisplayName</key>
<string>Sambad Secure</string>
```

### Step 2: Update pubspec.yaml (Optional)

Edit `frontend/pubspec.yaml`:

```yaml
name: sambad_secure  # or your chosen name
description: "Sambad Secure - Private messaging app"
```

### Step 3: Rebuild

```bash
cd frontend
flutter clean
flutter pub get
./build_ipa.sh
```

### Step 4: Check App Store Availability

Before finalizing, check if the name is available:

1. Go to: https://appstoreconnect.apple.com/
2. Click "My Apps" → "+" → "New App"
3. Try entering your chosen name
4. If it's taken, you'll see an error immediately
5. Keep trying different names until you find one available

## Quick Change Commands

```bash
# Change to "Sambad Secure"
cd frontend/ios/Runner
# Edit Info.plist and change CFBundleDisplayName

# Or use sed (replace "Sambad Secure" with your choice)
sed -i '' 's/<string>Private Sambad<\/string>/<string>Sambad Secure<\/string>/g' Info.plist

# Rebuild
cd ../../
flutter clean
./build_ipa.sh
```

## Name Requirements

Apple's requirements for app names:
- Maximum 30 characters
- Can include letters, numbers, spaces, hyphens
- Cannot include special characters like @, #, $, etc.
- Must be unique in the App Store
- Should be relevant to your app

## Recommended Approach

1. **Choose 3-5 backup names** in case your first choice is taken
2. **Check availability** in App Store Connect before building
3. **Update the name** in Info.plist
4. **Rebuild** the IPA
5. **Submit** to App Store

## Current Name Locations

The app name appears in these files:
- `frontend/ios/Runner/Info.plist` (CFBundleDisplayName)
- `frontend/ios/Runner/Info.plist` (CFBundleName)
- `frontend/pubspec.yaml` (name field)
- `frontend/lib/main.dart` (title in MaterialApp)

## Example: Change to "Sambad Secure"

1. Edit `frontend/ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleDisplayName</key>
   <string>Sambad Secure</string>
   <key>CFBundleName</key>
   <string>Sambad Secure</string>
   ```

2. Edit `frontend/lib/main.dart`:
   ```dart
   MaterialApp(
     title: 'Sambad Secure',
     // ...
   )
   ```

3. Rebuild:
   ```bash
   cd frontend
   flutter clean
   flutter pub get
   ./build_ipa.sh
   ```

## Verification

After changing the name:
1. Run the app: `flutter run`
2. Check the home screen - should show new name
3. Check app switcher - should show new name
4. Build IPA and upload to App Store Connect

## Tips

- **Keep it short**: Easier to remember and fits better on home screen
- **Make it searchable**: Include keywords like "chat", "messenger", "secure"
- **Check trademarks**: Ensure you're not infringing on existing trademarks
- **Test on device**: See how it looks on actual home screen

## Need Help Choosing?

Consider these factors:
1. **Brand identity**: Does it match your brand?
2. **Searchability**: Will users find it when searching?
3. **Memorability**: Is it easy to remember?
4. **Availability**: Is it available in App Store?
5. **Domain**: Is the domain available for website?

---

**Recommended:** Try "Sambad Secure" or "Sambad Messenger" first, as they're descriptive and likely available.
