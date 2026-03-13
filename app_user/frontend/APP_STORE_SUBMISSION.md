# App Store Submission Guide for Private Sambad

## Prerequisites

Before submitting to the App Store, you need:

1. **Apple Developer Account** ($99/year)
   - Sign up at: https://developer.apple.com/programs/

2. **App Store Connect Access**
   - Access at: https://appstoreconnect.apple.com/

3. **Certificates & Provisioning Profiles**
   - Distribution Certificate
   - App Store Provisioning Profile

## Step 1: Prepare Your App Information

### App Details
- **App Name**: Private Sambad
- **Bundle ID**: com.shamrai.sambad
- **Version**: 1.0.0
- **Category**: Social Networking
- **Age Rating**: 4+ (or appropriate rating)

### Required Assets
- App Icon (1024x1024 PNG, no transparency)
- Screenshots (iPhone 6.7", 6.5", 5.5" displays)
- App Preview Video (optional but recommended)

### App Description
```
Private Sambad - Secure & Private Messaging

Stay connected with friends and family through end-to-end encrypted messaging. 
Your privacy is our priority.

Features:
• End-to-end encrypted messages
• Private one-on-one chats
• Group conversations
• AI assistant for help
• Simple and intuitive interface
• No message storage on servers

Your messages are stored locally on your device only. We never have access to your conversations.
```

### Keywords
```
messaging, chat, secure, private, encrypted, communication, social
```

## Step 2: Configure Xcode Project

### Update Info.plist
Already configured with:
- Camera permission
- Photo library permission
- Contacts permission

### Update Version and Build Number
```bash
cd frontend/ios
# Edit Runner/Info.plist
# CFBundleShortVersionString: 1.0.0
# CFBundleVersion: 1
```

## Step 3: Create Certificates (First Time Only)

### A. Create Distribution Certificate

1. Open Xcode
2. Go to: Xcode → Settings → Accounts
3. Select your Apple ID
4. Click "Manage Certificates"
5. Click "+" → "Apple Distribution"

### B. Create App ID

1. Go to: https://developer.apple.com/account/resources/identifiers/list
2. Click "+" to create new identifier
3. Select "App IDs" → Continue
4. Select "App" → Continue
5. Description: Private Sambad
6. Bundle ID: com.shamrai.sambad (Explicit)
7. Capabilities: Enable required capabilities
8. Click "Continue" → "Register"

### C. Create Provisioning Profile

1. Go to: https://developer.apple.com/account/resources/profiles/list
2. Click "+" to create new profile
3. Select "App Store" → Continue
4. Select your App ID (com.shamrai.sambad)
5. Select your Distribution Certificate
6. Name: Private Sambad App Store
7. Click "Generate" → Download the profile

## Step 4: Configure Signing in Xcode

```bash
cd frontend
open ios/Runner.xcworkspace
```

In Xcode:
1. Select "Runner" project in navigator
2. Select "Runner" target
3. Go to "Signing & Capabilities" tab
4. **Uncheck** "Automatically manage signing"
5. Select your Team
6. Provisioning Profile: Select the App Store profile you created
7. Repeat for "Release" configuration

## Step 5: Create App in App Store Connect

1. Go to: https://appstoreconnect.apple.com/
2. Click "My Apps" → "+" → "New App"
3. Fill in:
   - Platform: iOS
   - Name: Private Sambad
   - Primary Language: English
   - Bundle ID: com.shamrai.sambad
   - SKU: com.shamrai.sambad.1
   - User Access: Full Access
4. Click "Create"

## Step 6: Build Archive for App Store

### Option A: Using Flutter Command (Recommended)

```bash
cd frontend

# Clean previous builds
flutter clean
flutter pub get

# Build for App Store
flutter build ipa --release

# The IPA will be created at:
# build/ios/ipa/Private Sambad.ipa
```

### Option B: Using Xcode

```bash
cd frontend
open ios/Runner.xcworkspace
```

In Xcode:
1. Select "Any iOS Device (arm64)" as destination
2. Product → Archive
3. Wait for archive to complete
4. Organizer window will open automatically

## Step 7: Upload to App Store Connect

### Using Xcode Organizer

1. In Organizer, select your archive
2. Click "Distribute App"
3. Select "App Store Connect" → Next
4. Select "Upload" → Next
5. Select distribution options:
   - ✓ Include bitcode for iOS content
   - ✓ Upload your app's symbols
   - ✓ Manage Version and Build Number (Xcode will handle)
6. Select "Automatically manage signing" → Next
7. Review the app information → Upload
8. Wait for upload to complete (may take 5-15 minutes)

### Using Transporter App (Alternative)

1. Download Transporter from Mac App Store
2. Open Transporter
3. Sign in with your Apple ID
4. Drag and drop the IPA file
5. Click "Deliver"

## Step 8: Complete App Store Connect Listing

1. Go to: https://appstoreconnect.apple.com/
2. Select your app "Private Sambad"
3. Click on version "1.0.0"

### Fill in Required Information:

#### App Information
- Subtitle: Secure Private Messaging
- Privacy Policy URL: (You need to host this)
- Category: Social Networking
- Secondary Category: (optional)

#### Pricing and Availability
- Price: Free
- Availability: All countries (or select specific)

#### App Privacy
- Click "Get Started"
- Answer questions about data collection
- For messaging app, typically:
  - Contact Info: Phone number (for authentication)
  - User Content: Messages (stored locally only)
  - Usage Data: None

#### Screenshots
Upload screenshots for:
- 6.7" Display (iPhone 14 Pro Max, 15 Pro Max, 16 Pro Max)
- 6.5" Display (iPhone 11 Pro Max, XS Max)
- 5.5" Display (iPhone 8 Plus)

Required: At least 3 screenshots per size

#### App Review Information
- First Name: [Your Name]
- Last Name: [Your Last Name]
- Phone: [Your Phone]
- Email: [Your Email]
- Sign-in required: Yes
- Demo Account:
  - Username: +917045249564 (test phone)
  - Password: (OTP will be sent)
- Notes: "Use test phone number for Firebase Phone Auth"

#### Version Information
- What's New in This Version: "Initial release of Private Sambad"

#### Build
- Click "+" next to Build
- Select the build you uploaded
- Click "Done"

## Step 9: Submit for Review

1. Review all information
2. Click "Add for Review" (top right)
3. Answer export compliance questions:
   - Does your app use encryption? Yes
   - Is it exempt? Yes (standard encryption)
4. Click "Submit for Review"

## Step 10: Wait for Review

- Review typically takes 1-3 days
- You'll receive email updates
- Check status in App Store Connect

## Important Notes

### Firebase Configuration
⚠️ **CRITICAL**: Before submitting, you MUST:
1. Replace `ios/Runner/GoogleService-Info.plist` with real credentials from Firebase Console
2. Current file has placeholder credentials and won't work in production

### Privacy Policy
You need to host a privacy policy. Sample content:

```
Privacy Policy for Private Sambad

Your privacy is important to us. Private Sambad:
- Uses phone number for authentication only
- Stores all messages locally on your device
- Does not store messages on our servers
- Uses end-to-end encryption
- Does not share your data with third parties
- Does not track your usage

Contact: [your-email@example.com]
```

Host this on:
- Your website
- GitHub Pages
- Or use a privacy policy generator

### App Review Tips

1. **Test thoroughly** before submitting
2. **Provide clear demo account** instructions
3. **Respond quickly** to reviewer questions
4. **Be patient** - first submission may be rejected for minor issues

### Common Rejection Reasons

1. Missing privacy policy
2. App crashes on launch
3. Incomplete functionality
4. Missing demo account
5. Misleading screenshots
6. Guideline violations

## Quick Build Script

Save this as `build_for_appstore.sh`:

```bash
#!/bin/bash

echo "🚀 Building Private Sambad for App Store..."

cd frontend

# Clean
echo "🧹 Cleaning..."
flutter clean
rm -rf build/
rm -rf ios/Pods/
rm -rf ios/.symlinks/

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get
cd ios && pod install && cd ..

# Build
echo "🔨 Building IPA..."
flutter build ipa --release

echo "✅ Build complete!"
echo "📦 IPA location: build/ios/ipa/Private Sambad.ipa"
echo ""
echo "Next steps:"
echo "1. Upload IPA to App Store Connect"
echo "2. Complete app listing"
echo "3. Submit for review"
```

## Useful Commands

```bash
# Check Flutter setup
flutter doctor -v

# List available devices
flutter devices

# Build for specific configuration
flutter build ipa --release --flavor production

# Validate IPA
xcrun altool --validate-app -f build/ios/ipa/Private\ Sambad.ipa -t ios -u your@email.com

# Upload IPA via command line
xcrun altool --upload-app -f build/ios/ipa/Private\ Sambad.ipa -t ios -u your@email.com
```

## Support Resources

- App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- App Store Connect Help: https://help.apple.com/app-store-connect/
- Flutter iOS Deployment: https://docs.flutter.dev/deployment/ios
- Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/

## Checklist Before Submission

- [ ] Apple Developer Account active
- [ ] Real Firebase credentials configured
- [ ] App tested on real device
- [ ] All features working
- [ ] Privacy policy hosted
- [ ] App icon ready (1024x1024)
- [ ] Screenshots prepared
- [ ] App description written
- [ ] Distribution certificate created
- [ ] Provisioning profile created
- [ ] App created in App Store Connect
- [ ] Build uploaded successfully
- [ ] All App Store Connect fields filled
- [ ] Demo account credentials provided
- [ ] Export compliance answered
- [ ] Ready to submit!

---

Good luck with your App Store submission! 🚀
