#!/usr/bin/env bash
# Xcode o‘rnatilgandan keyin iOS Simulator va Flutter uchun bir martalik sozlash.
set -euo pipefail

XCODE_APP=""
if [[ -d /Applications/Xcode.app ]]; then
  XCODE_APP="/Applications/Xcode.app"
elif [[ -d "$HOME/Downloads/Xcode.app" ]]; then
  XCODE_APP="$HOME/Downloads/Xcode.app"
  echo "Xcode Downloads da. Ilova bo‘lgani yaxshi: sudo mv \"$XCODE_APP\" /Applications/"
fi

if [[ -z "$XCODE_APP" ]]; then
  echo "Xcode topilmadi. O‘rnating, keyin skriptni qayta ishga tushiring."
  exit 1
fi

export DEVELOPER_DIR="$XCODE_APP/Contents/Developer"

if [[ "$XCODE_APP" == /Applications/Xcode.app ]]; then
  echo "Developer papkasi Xcode ga o‘tkazilmoqda (sudo parol so‘ralishi mumkin)..."
  sudo xcode-select --switch "$DEVELOPER_DIR"
  sudo xcodebuild -runFirstLaunch
fi

if ! command -v pod >/dev/null; then
  echo "CocoaPods o‘rnatilmoqda..."
  if command -v brew >/dev/null; then
    brew install cocoapods
  else
    sudo gem install cocoapods
  fi
fi

export PATH="${HOME}/.local/flutter/bin:${PATH}"
open -a Simulator
echo "Simulator ochildi. Ilovani ishga tushiring:"
echo "  cd \"$(cd "$(dirname "$0")/.." && pwd)\""
echo "  flutter pub get"
echo "  flutter devices"
echo "  flutter run"