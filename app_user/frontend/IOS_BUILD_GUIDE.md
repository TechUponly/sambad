# iOS Build Guide

## Prerequisites

Before building for iOS, ensure you have:

1. **macOS** with Xcode installed (latest version recommended)
2. **Flutter SDK** installed and configured
3. **CocoaPods** installed (`sudo gem install cocoapods`)
4. **Apple Developer Account** (for device testing and App Store distribution)
5. **iOS device** or simulator for testing

## Quick Build

### Option 1: Using the Build Script (Recommended)

```bash
cd frontend
./build_ios.sh
```

### Option 2: Manual Build

```bash
cd frontend

# Get dependencies
flutter pub get

# Clean previous builds
flutter clean

# Build for iOS (release mode)
flutter build ios --release

# Or build for debug mode
flutter build ios --debug
```

## Opening in Xcode

After building, open the project in Xcode:

```bash
cd frontend/ios
open Runner.xcworkspace
```

**Important:** Always open `Runner.xcworkspace`, NOT `Runner.xcodeproj`

## Configuration Steps in Xcode

### 1. Set Bundle Identifier
- Select `Runner` project in the navigator
- Go to `Signing & Capabilities` tab
- Update the Bundle Identifier to your unique identifier (e.g., `com.yourcompany.sambad`)

### 2. Configure Signing
- In `Signing & Capabilities`, select your Team
- Enable "Automatically manage signing"
- Xcode will create provisioning profiles automatically

### 3. Set Deployment Target
- In `General` tab, set the minimum iOS version
- Current Podfile suggests iOS 15.6 or higher

## Building for Different Purposes

### For Testing on Device

1. Connect your iOS device via USB
2. Select your device from the device dropdown in Xcode
3. Click the "Run" button (▶️) or press `Cmd + R`

### For App Store Distribution

1. In Xcode, go to `Product > Archive`
2. Wait for the archive to complete
3. In the Organizer window, click "Distribute App"
4. Follow the wizard to upload to App Store Connect

### For Ad Hoc Distribution

1. Create an archive as above
2. Choose "Ad Hoc" distribution
3. Export the IPA file
4. Distribute via TestFlight or direct installation

## Common Issues & Solutions

### Issue: "No provisioning profiles found"
**Solution:** 
- Ensure you're logged into Xcode with your Apple ID
- Go to Xcode > Preferences > Accounts
- Select your account and click "Download Manual Profiles"

### Issue: "Pod install failed"
**Solution:**
```bash
cd frontend/ios
pod deintegrate
pod install
```

### Issue: "Firebase configuration missing"
**Solution:**
- Ensure `GoogleService-Info.plist` exists in `frontend/ios/Runner/`
- Download from Firebase Console if missing

### Issue: "Signing certificate not found"
**Solution:**
- Go to Xcode > Preferences > Accounts
- Select your team and click "Manage Certificates"
- Create a new iOS Development certificate

## Build Configurations

### Debug Build
```bash
flutter build ios --debug
```
- Includes debugging symbols
- Larger app size
- Better for development

### Release Build
```bash
flutter build ios --release
```
- Optimized and minified
- Smaller app size
- For production/App Store

### Profile Build
```bash
flutter build ios --profile
```
- Performance profiling enabled
- For testing performance

## App Permissions

The app requires the following permissions (already configured in Info.plist):

- **Contacts Access** (`NSContactsUsageDescription`): For syncing contacts

If you add more features, you may need to add:
- Camera: `NSCameraUsageDescription`
- Photo Library: `NSPhotoLibraryUsageDescription`
- Microphone: `NSMicrophoneUsageDescription`

## Version Management

Version is managed in `pubspec.yaml`:
```yaml
version: 4.0.9+4
```
- `4.0.9` = Version name (CFBundleShortVersionString)
- `4` = Build number (CFBundleVersion)

To update:
```bash
# Update version in pubspec.yaml, then rebuild
flutter build ios --build-name=4.0.10 --build-number=5
```

## Testing

### Run on Simulator
```bash
flutter run -d "iPhone 15 Pro"
```

### Run on Physical Device
```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

## Troubleshooting Commands

```bash
# Clean Flutter build cache
flutter clean

# Update pods
cd ios && pod update && cd ..

# Reinstall pods
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..

# Check Flutter doctor
flutter doctor -v

# Verify iOS setup
flutter doctor --verbose
```

## Resources

- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [CocoaPods Guide](https://guides.cocoapods.org/)

## Support

For issues specific to this project, check:
- Backend setup: `backend/README.md`
- Database schema: `backend/DB_SCHEMA.md`
- App logic: `frontend/lib/`
