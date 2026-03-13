# iOS Build - Quick Reference

## 🚀 Quick Start

```bash
cd frontend
./build_ios.sh
```

## 📱 Open in Xcode

```bash
open frontend/ios/Runner.xcworkspace
```

## ⚡ Fast Commands

### Build Release
```bash
cd frontend
flutter build ios --release
```

### Build Debug
```bash
cd frontend
flutter build ios --debug
```

### Run on Simulator
```bash
cd frontend
flutter run -d "iPhone 15 Pro"
```

### Run on Device
```bash
cd frontend
flutter run
# Select your device from the list
```

## 🔧 Fix Common Issues

### Reset Pods
```bash
cd frontend/ios
rm -rf Pods Podfile.lock
pod install
```

### Clean Build
```bash
cd frontend
flutter clean
flutter pub get
```

## 📦 Before App Store

1. Update version in `pubspec.yaml`
2. Open Xcode: `open ios/Runner.xcworkspace`
3. Product → Archive
4. Distribute App → App Store Connect

## ✅ Checklist

- [ ] Xcode installed (16.4+)
- [ ] Apple Developer account configured
- [ ] Bundle ID set in Xcode
- [ ] Signing certificate configured
- [ ] GoogleService-Info.plist present
- [ ] Version number updated

## 📞 Need Help?

See full guide: `IOS_BUILD_GUIDE.md`
