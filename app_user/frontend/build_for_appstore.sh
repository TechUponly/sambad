#!/bin/bash

echo "🚀 Building Private Sambad for App Store..."
echo ""

cd "$(dirname "$0")"

# Clean
echo "🧹 Cleaning previous builds..."
flutter clean
rm -rf build/
rm -rf ios/Pods/
rm -rf ios/.symlinks/

# Get dependencies
echo ""
echo "📦 Getting dependencies..."
flutter pub get

echo ""
echo "📦 Installing iOS pods..."
cd ios && pod install && cd ..

# Build
echo ""
echo "🔨 Building IPA for App Store..."
flutter build ipa --release

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build complete!"
    echo ""
    echo "📦 IPA location: build/ios/ipa/Private Sambad.ipa"
    echo ""
    echo "Next steps:"
    echo "1. Open Transporter app (download from Mac App Store if needed)"
    echo "2. Drag and drop the IPA file into Transporter"
    echo "3. Click 'Deliver' to upload to App Store Connect"
    echo ""
    echo "OR use Xcode:"
    echo "1. Open ios/Runner.xcworkspace in Xcode"
    echo "2. Product → Archive"
    echo "3. Distribute App → App Store Connect"
    echo ""
else
    echo ""
    echo "❌ Build failed! Please check the errors above."
    exit 1
fi
