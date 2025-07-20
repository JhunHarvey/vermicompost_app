# VermicompostApp

A Flutter application for monitoring and managing your vermicomposting system. The app provides real-time data on moisture, temperature, water level, and vermitea level, and includes notification and contact features.

## Features

- **Dashboard:** View live data for moisture, temperature, water tank, and vermitea levels.
- **Notifications:** Get alerts for important events (e.g., low moisture, tank refill needed).
- **Contact Tab:** Contact support or view help information.
- **Valve Control:** Remotely toggle the valve state.
- **Portrait Mode Only:** The app is locked to portrait orientation for best usability.

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart
- A device or emulator

### Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/your-username/vermicompost_app.git
   cd vermicompost_app/vc_monitoring_systemv1
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Run the app:**
   ```sh
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

## License

This project is licensed under the MIT License.

---
