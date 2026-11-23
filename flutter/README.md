# Ilm Fan — mobil (Flutter)

Sertifikat imtihoniga tayyorlov ilovasi. Backend va veb: `../backend`, `../frontend`.

## Talablar

Flutter SDK: `~/.local/flutter` (yoki o‘zingizning `PATH`ingizdagi `flutter`).

```bash
export PATH="$HOME/.local/flutter/bin:$PATH"
flutter doctor
```

## Ishlatish

```bash
source ~/.zshrc   # birinchi marta PATH uchun
cd flutter
flutter pub get
flutter devices   # qaysi qurilmalar bor
```

### MacBookda qayerda ishga tushirish

| Usul | Nima kerak | Buyruq |
|------|------------|--------|
| **Brauzer** | faqat Chrome | `flutter run -d chrome` |
| **iOS Simulator** | to‘liq **Xcode** (App Store, ~12 GB) | qarang pastdagi bo‘lim |
| **Android emulyator** | Android Studio → SDK + virtual device | `flutter run` |

Flutter o‘zining emulyatori yo‘q. iPhone oynasi **Simulator** — faqat Xcode bilan keladi (Command Line Tools yetmaydi).

#### iOS Simulator (bir marta)

1. **App Store’dagi eng yangi Xcode** ba’zan faqat macOS **26.6+** talab qiladi. Sizda **26.5.1** bo‘lsa, ikki yo‘l:
   - **Tavsiya:** Apple hisobingiz bilan [developer.apple.com/download/all](https://developer.apple.com/download/all/) dan **Xcode 26.6** (`.xip`) — macOS **26.2+** da ishlaydi, Simulator bor.
   - Yoki **System Settings → General → Software Update** → macOS **26.7** yoki yangiroqni o‘rnating, keyin App Store’dan Xcode.
2. Xcode ni bir marta ochib, litsenziyani qabul qiling.
3. Terminalda:

```bash
./scripts/ios-simulator-setup.sh
```

4. Ilovani simulyatorda:

```bash
source ~/.zshrc
cd flutter
flutter pub get
flutter run
```

Hozir Mac’da faqat **Command Line Tools** bor — Simulator hali ishlamaydi. Xcode tugagach, skript yoki yuqoridagi qadamlar yetarli.

Loyiha: `lib/main.dart` (bosh nuqta — **kirish** oqimi), nomi `ilm_fan`.