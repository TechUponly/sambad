# iOS Bundle ID Details: com.shamrai.sambad

## App Information

**Bundle Identifier:** `com.shamrai.sambad`
**App Name:** Private Sambad
**Display Name:** Private Sambad
**Version:** 4.0.9
**Build Number:** 5

## Developer Information

**Team ID:** M8T6L9G4ZU
**Developer Account:** Associated with your Apple Developer Program

## Firebase iOS Configuration

**iOS App ID:** `1:1046904512204:ios:3eeca3ee2466a65e12ac69`
**API Key:** `AIzaSyDhZ_Pbzco7eF-mfTpeLusIpSveV8WUDPU`
**Project ID:** `private-sambad`
**Storage Bucket:** `private-sambad.firebasestorage.app`

## App Capabilities & Permissions

### Required Permissions (Info.plist):
- **Camera Usage:** "Sambad needs camera access to take photos and videos for sharing in chats."
- **Photo Library Usage:** "Sambad needs photo library access to share images and videos in chats."
- **Photo Library Add Usage:** "Sambad needs permission to save photos and videos to your library."
- **Contacts Usage:** "Sambad is an end-to-end encrypted messaging app. Auto-sync helps you connect and invite friends to chat securely."

### URL Schemes:
- `com.googleusercontent.apps.1046904512204-placeholder`
- `app-1-1046904512204-ios-3eeca3ee2466a65e12ac69`

## Build Configuration

**Deployment Target:** iOS 15.6+
**Supported Devices:** iPhone, iPad
**Architectures:** arm64 (Apple Silicon)

**Supported Orientations:**
- Portrait
- Landscape Left
- Landscape Right

**iPad Orientations:**
- Portrait
- Portrait Upside Down
- Landscape Left
- Landscape Right

## App Store Connect Information

### App Category
- **Primary Category:** Social Networking
- **Secondary Category:** (Optional)

### App Description
```
Private Sambad - Secure & Private Messaging

Stay connected with friends and family through end-to-end encrypted messaging. Your privacy is our priority.

Features:
• End-to-end encrypted messages
• Private one-on-one chats
• Group conversations
• AI assistant for help
• Simple and intuitive interface
• No message storage on servers
• Smart OTP entry for quick login
• Profile customization
• Contact synchronization

Your messages are stored locally on your device only. We never have access to your conversations.

Download Private Sambad today for secure, private communication with the people who matter most.
```

### Keywords
```
messaging, chat, secure, private, encrypted, communication, social, sambad, end-to-end, privacy
```

### App Store Screenshots Required
- iPhone 6.7" Display (iPhone 14 Pro Max, 15 Pro Max, 16 Pro Max): 1290 x 2796 pixels
- iPhone 6.5" Display (iPhone 11 Pro Max, XS Max): 1242 x 2688 pixels
- iPhone 5.5" Display (iPhone 8 Plus): 1242 x 2208 pixels

## Privacy Policy Requirements

**Privacy Policy URL:** (Required - must be hosted)

### Data Collection Summary:
- **Contact Information:** Phone number (for authentication only)
- **User Content:** Messages (stored locally, end-to-end encrypted)
- **Usage Data:** None collected

### Privacy Practices:
- End-to-end encryption for all messages
- No server-side message storage
- Local device storage only
- No data sharing with third parties
- No tracking or analytics

## Code Signing

**Signing Certificate:** Apple Distribution
**Provisioning Profile:** App Store Distribution Profile
**Automatic Signing:** Disabled (manual signing configured)

## Firebase Setup Status

### Current Configuration:
- ✅ iOS app configured in Firebase
- ✅ GoogleService-Info.plist included
- ✅ Firebase Auth enabled
- ⚠️ **Action Required:** Replace placeholder credentials with production credentials

### Production Setup Required:
1. Download real GoogleService-Info.plist from Firebase Console
2. Replace current placeholder file
3. Rebuild IPA with production credentials

## Build Files

**IPA Location:** `build/ios/ipa/Private Sambad.ipa`
**Archive Location:** `build/ios/archive/Runner.xcarchive`
**Size:** ~25 MB

## App Store Submission Checklist

- [ ] Apple Developer Account active ($99/year)
- [ ] App created in App Store Connect
- [ ] Real Firebase credentials configured
- [ ] Privacy policy hosted and accessible
- [ ] App description and keywords finalized
- [ ] Screenshots prepared (all required sizes)
- [ ] App icon ready (1024x1024 PNG)
- [ ] Build uploaded to App Store Connect
- [ ] App Store listing completed
- [ ] Age rating assigned
- [ ] Pricing set (Free)
- [ ] Export compliance answered
- [ ] Ready for review submission

## Technical Specifications

**Minimum iOS Version:** 15.6
**Swift Version:** 5.x
**Xcode Version:** Latest stable
**Flutter Version:** 3.x

**Dependencies:**
- Firebase Core
- Firebase Auth
- Flutter Contacts
- Image Picker
- Shared Preferences
- Provider (State Management)
- Permission Handler
- Screen Protector

## Support Information

**Developer Contact:** (Your contact information)
**Support Email:** (Your support email)
**Website:** (Optional)

## App Store Review Guidelines Compliance

- ✅ No objectionable content
- ✅ Proper privacy policy
- ✅ Clear app functionality
- ✅ No misleading information
- ✅ Follows iOS Human Interface Guidelines
- ✅ Proper permission usage descriptions
- ✅ No private API usage

## Marketing Information

**App Subtitle:** "Secure Private Messaging"
**Promotional Text:** "End-to-end encrypted messaging for your privacy"

**What's New in Version 4.0.9:**
"Initial release of Private Sambad - secure messaging with end-to-end encryption, smart OTP login, and complete privacy protection."

---

## Quick Commands

```bash
# Build IPA
flutter build ipa --release

# Open in Xcode
open ios/Runner.xcworkspace

# Check signing
codesign -dv --verbose=4 "build/ios/ipa/Private Sambad.ipa"

# Upload to App Store (via Xcode)
# Product → Archive → Distribute App → App Store Connect
```

This bundle ID is ready for App Store submission once you complete the Firebase production setup and privacy policy hosting.