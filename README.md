# VermicompostApp

A Flutter application for monitoring and managing a vermicomposting system. The app reads live sensor values (moisture, temperature, water tank level, vermiwash/vermitea level), displays a dashboard, sends notifications for important events, and provides a contact/help tab and basic valve control.

## Key Features

- **Dashboard:** View live data for moisture, temperature, water tank, and vermitea levels.
- **Notifications:** Get alerts for important events (e.g., low moisture, tank refill needed).
- **Contact Tab:** Contact support or view help information.
- **Valve Control:** Remotely toggle the valve state.
- **Portrait Mode Only:** The app is locked to portrait orientation for best usability.

## Getting Started

### Prerequisites

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

## Project Structure

- `lib/main.dart` - App entry point and main navigation.
- `lib/home_page.dart` - Dashboard with monitoring cards.
- `lib/notifications.dart` - Notification tab and logic.
- `lib/contacttab.dart` - Contact/help tab.

## Customization

- **Logo:** Replace `assets/images/logo.png` with your own logo.
- **Theme:** Modify `ThemeData` in `main.dart` for custom fonts and colors.
- **Notification Logic:** Update `NotificationItem` list in `notifications.dart` for your own alerts.

---
