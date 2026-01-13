# VermicompostApp

A Flutter application for monitoring and managing a vermicomposting system. The app reads live sensor values (moisture, temperature, water tank level, vermiwash/vermitea level), displays a dashboard, sends notifications for important events, and provides a contact/help tab and basic valve control.

## Key Features

- Dashboard with live sensor values (temperature, moisture, water tank, vermiwash)
- Push notifications (Firebase Cloud Messaging) with background handler
- Contact / help tab
- Valve/pump toggle from the app
- Locked to portrait orientation for consistent UI

## Repository Layout

- `lib/main.dart` — App entry, navigation, Firebase + FCM setup, and background message handler
- `lib/home_page.dart` — Dashboard view and valve control
- `lib/notifications.dart` — Notification UI and list
- `lib/contacttab.dart` — Contact/help tab
- `lib/notification_service.dart` — Local notification wrapper and checks
- `android/`, `ios/`, `windows/`, `web/` — Platform code and configs

## Prerequisites

- Flutter SDK (stable channel) — see the official Flutter docs
- Dart (comes with Flutter)
- Android Studio / AVD or a connected Android device (or Windows desktop target)
- A Firebase project and platform config files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS)

## Setup (Windows / PowerShell)

1. Open PowerShell and change to the Flutter project folder:
```powershell
cd C:\VermicompostApp\vc_monitoring_systemv1
```

2. Run `flutter pub get` to install dependencies.

3. Connect your Android device or start an emulator.

4. Run the app:
```powershell
flutter run
```

## Customization

- **Logo:** Replace `assets/images/logo.png` with your own logo.
- **Theme:** Modify `ThemeData` in `main.dart` for custom fonts and colors.
- **Notification Logic:** Update `NotificationItem` list in `notifications.dart` for your own alerts.

## License

This project is licensed under the MIT License.

---
