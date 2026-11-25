# #0001 flutter build apk --release failed on :image_picker_android:lintVitalAnalyzeRelease with NoSuchMethodError: java.util.List.removeLast() because JDK 17 was used instead of JDK 21 required by newer Android Lint.

- 2026-11-24T10:42:30Z `issue`: flutter build apk --release failed on :image_picker_android:lintVitalAnalyzeRelease with NoSuchMethodError: java.util.List.removeLast() because JDK 17 was used instead of JDK 21 required by newer Android Lint. [flutter/android (image_picker_android:lintVitalAnalyzeRelease)]
- 2026-11-24T10:43:51Z `fix`: Installed Eclipse Temurin JDK 21 (arm64) at ~/.local/jdk-21 and pointed Flutter to it via flutter config --jdk-dir. flutter build apk --release succeeded in 31.6s, producing build/app/outputs/flutter-apk/app-release.apk (52.2MB).
