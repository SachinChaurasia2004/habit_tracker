# Habitus release checklist

## Required account-owned configuration

- Replace `com.example.habit_tracker` in `android/app/build.gradle.kts` with an application ID owned by the publisher (for example, `com.yourcompany.habitus`). Update the Android Kotlin package path to match.
- Set a matching unique iOS bundle identifier in Xcode and select the Apple Developer signing team.
- Create Android upload-key signing credentials and configure the `release` build type to use them. Never commit the keystore or its passwords.
- Create a public privacy-policy URL. The app stores habit and profile data locally and can request notification permission; disclose both accurately in the store listing.
- Prepare store listing assets: 512×512 Android icon, screenshots for supported device sizes, feature graphic (Google Play), description, support email, and privacy-policy URL.

## Verify before submission

- Test first launch, onboarding name entry, profile editing, notification permission, habit creation/completion, and profile reset on a physical device.
- Run `flutter analyze` and `flutter test`.
- Build Android with `flutter build appbundle --release` and upload the `.aab` to Play Console internal testing first.
- Build iOS with `flutter build ipa --release`, validate the archive in Xcode, then test with TestFlight.
- Review permission declarations. In particular, confirm `SCHEDULE_EXACT_ALARM` is essential for your reminder design before Play submission because it is subject to Google Play policy.

## Current release metadata

- Display name: `Habitus`
- Version: `1.0.0+1` (set in `pubspec.yaml`)
- Android and iOS launcher icons are configured from `assets/images/logo.png`.
