#!/bin/bash
set -e
EMU="$HOME/Library/Android/sdk/emulator/emulator"
AVD="${1:-Medium_Phone_API_36.1}"

echo "Starting Android emulator: $AVD"
"$EMU" -avd "$AVD" &
sleep 20

echo "Running Flutter on emulator..."
flutter run -d emulator-5554
