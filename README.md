# Bible Compass

## Run in Android Studio

1. Install the Flutter and Dart plugins in Android Studio.
2. Open the repository root (`bible_compass_app`), which contains `pubspec.yaml`.
3. Set the Flutter SDK path to your Flutter installation (on this machine: `/Users/lordscoba/flutter`).
4. In Settings → Build, Execution, Deployment → Build Tools → Gradle, select **JDK 17** as the Gradle JDK. On this machine it is installed at `/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home`. If opening the `android` folder separately, its `GRADLE_LOCAL_JAVA_HOME` setting must also resolve to JDK 17.
5. Run `flutter pub get` from the project root.
6. Start an Android emulator in Device Manager, or connect a phone with USB debugging enabled.
7. Select `lib/main.dart`, choose the Android device, and press Run.

The Android build uses Gradle 8.14.6, Android Gradle Plugin 8.11.1, and Kotlin 2.2.20 to meet the installed Flutter 3.47.8 SDK's minimum requirements. Keep the Kotlin and DSL compatibility flags in `android/gradle.properties` while using this AGP 8 configuration.

Install Android SDK Platform 36 and the Flutter SDK's required NDK (28.2.13676358 with Flutter 3.47.8) through SDK Manager if they are missing. `android/local.properties` should contain your own `sdk.dir` and `flutter.sdk` paths; this file is local to each machine.

## Verify the Android build

```sh
flutter doctor -v
flutter pub get
flutter build apk --debug
```

The debug APK is written to `build/app/outputs/flutter-apk/app-debug.apk`.

Release signing uses the private `android/key.properties` file and its referenced keystore. Keep these files out of version control.
