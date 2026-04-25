# IPA Build Guide for Private Sambad

## Overview

This guide covers creating an IPA file for iOS distribution. There are two types:
1. **Unsigned IPA** - For testing/development (created by script)
2. **Signed IPA** - For real devices, TestFlight, App Store (requires Xcode)

## Quick Build (Unsigned IPA)

```bash
cd frontend
./build_ipa.sh
```

This creates `PrivateSambad.ipa` - an unsigned IPA for testing purposes.

## Building Signed IPA (For Real Devices)

### Prerequisites

1. **Apple Developer Account** ($99/year)
   - Sign up at: https://developer.apple.com/

2. **Xcode with Signing Configured**
   - Install Xcode from App Store
   - Add your Apple ID in Xcode → Preferences → Accounts

3. **Provisioning Profile**
   - Automatically managed by Xcode, or
   - Manually created in Apple Developer Portal

### Step-by-Step: Create Signed IPA

#### 1. Open Project in Xcode

```bash
cd frontend
open ios/Runner.xcworkspace
```

#### 2. Configure Signing

1. Select **Runner** project in navigator
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Check "Automatically manage signing"
5. Select your **Team** from dropdown
6. Verify Bundle Identifier: `com.sambad.messenger`

#### 3. Select Build Destination

- For real device: Connect iPhone/iPad via USB, select it
- For generic device: Select "Any iOS Device (arm64)"

#### 4. Create Archive

1. Menu: **Product → Archive**
2. Wait for build to complete (may take 5-10 minutes)
3. Organizer window will open automatically

#### 5. Distribute IPA

In the Organizer window:

##### Option A: Ad Hoc Distribution (Direct Install)

1. Click **Distribute App**
2. Select **Ad Hoc**
3. Click **Next**
4. Select distribution options:
   - App Thinning: None
   - Rebuild from Bitcode: No
   - Strip Swift symbols: Yes
5. Click **Next**
6. Review signing certificate
7. Click **Export**
8. Choose save location
9. IPA file will be created

##### Option B: TestFlight (Beta Testing)

1. Click **Distribute App**
2. Select **App Store Connect**
3. Click **Upload**
4. Follow prompts to upload to TestFlight
5. Manage testers in App Store Connect

##### Option C: App Store (Production)

1. Click **Distribute App**
2. Select **App Store Connect**
3. Click **Upload**
4. Go to App Store Connect to submit for review

## Alternative: Command Line Build

### Build Archive

```bash
cd frontend/ios

# Clean
xcodebuild clean -workspace Runner.xcworkspace -scheme Runner

# Archive
xcodebuild archive \
  -workspace Runner.xcworkspace \
  -scheme Runner \
  -archivePath build/Runner.xcarchive \
  -configuration Release \
  CODE_SIGN_IDENTITY="iPhone Distribution" \
  PROVISIONING_PROFILE_SPECIFIER="YourProvisioningProfile"
```

### Export IPA

```bash
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportPath build \
  -exportOptionsPlist ExportOptions.plist
```

You'll need to create `ExportOptions.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>compileBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
```

## Installing IPA on Device

### Method 1: Xcode

1. Connect device via USB
2. Open Xcode → Window → Devices and Simulators
3. Select your device
4. Click "+" under Installed Apps
5. Select your IPA file

### Method 2: Apple Configurator

1. Install Apple Configurator from App Store
2. Connect device
3. Double-click device
4. Click "Add" → "Apps"
5. Select IPA file

### Method 3: TestFlight

1. Upload to TestFlight (see above)
2. Install TestFlight app on device
3. Accept invitation
4. Install app from TestFlight

## Troubleshooting

### Error: "No signing certificate found"

**Solution:**
1. Xcode → Preferences → Accounts
2. Select your Apple ID
3. Click "Manage Certificates"
4. Click "+" → "Apple Development" or "Apple Distribution"

### Error: "Provisioning profile doesn't match"

**Solution:**
1. In Xcode, go to Signing & Capabilities
2. Uncheck "Automatically manage signing"
3. Check it again
4. Select your team again

### Error: "Bundle identifier is already in use"

**Solution:**
1. Change Bundle ID in Xcode
2. Update Firebase configuration to match
3. Or use a different Bundle ID

### Error: "Code signing entitlements error"

**Solution:**
1. Check Signing & Capabilities tab
2. Remove any invalid capabilities
3. Ensure all capabilities are enabled in Apple Developer Portal

## Build Configuration

### Release vs Debug

- **Debug**: Includes debugging symbols, larger size
  ```bash
  flutter build ios --debug
  ```

- **Release**: Optimized, smaller size, for distribution
  ```bash
  flutter build ios --release
  ```

- **Profile**: For performance testing
  ```bash
  flutter build ios --profile
  ```

### Build Modes

- `--no-codesign`: Build without signing (for CI/CD)
- `--obfuscate`: Obfuscate Dart code
- `--split-debug-info`: Extract debug info

## App Store Submission Checklist

- [ ] App icons configured (all sizes)
- [ ] Launch screen configured
- [ ] Bundle ID matches App Store Connect
- [ ] Version number updated in pubspec.yaml
- [ ] Build number incremented
- [ ] Privacy policy URL ready
- [ ] App description and screenshots prepared
- [ ] All required capabilities enabled
- [ ] Tested on real device
- [ ] No placeholder/test data
- [ ] Firebase properly configured
- [ ] All permissions have usage descriptions

## Version Management

Update version in `pubspec.yaml`:

```yaml
version: 4.0.9+4
```

- `4.0.9` = Version name (CFBundleShortVersionString)
- `4` = Build number (CFBundleVersion)

Or via command line:

```bash
flutter build ios --build-name=4.0.10 --build-number=5
```

## File Sizes

Typical IPA sizes:
- Debug: 50-100 MB
- Release: 20-40 MB
- After App Store optimization: 10-20 MB

## Distribution Methods Comparison

| Method | Use Case | Requires | Device Limit |
|--------|----------|----------|--------------|
| Development | Testing during development | Dev account | 3 devices |
| Ad Hoc | Beta testing | Dev account | 100 devices |
| TestFlight | Public beta | Dev account | 10,000 testers |
| App Store | Public release | Dev account | Unlimited |

## Next Steps After Building IPA

1. **Test thoroughly** on real devices
2. **Fix any issues** found during testing
3. **Prepare App Store listing**:
   - App name
   - Description
   - Keywords
   - Screenshots (all device sizes)
   - Privacy policy
4. **Submit for review**
5. **Monitor crash reports** in App Store Connect

## Resources

- [Apple Developer Portal](https://developer.apple.com/)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Xcode Documentation](https://developer.apple.com/documentation/xcode)

## Support

For issues:
1. Check Xcode console for detailed errors
2. Review Apple Developer documentation
3. Check Flutter iOS deployment guide
4. Verify all configurations match
