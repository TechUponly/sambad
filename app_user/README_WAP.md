# WAP (Web Application Platform) Dynamics Support — User App

## Overview
This user app is designed to support WAP (Web Application Platform) dynamics, enabling:
- Responsive web/mobile UI (via Flutter web)
- Dynamic content loading and updates
- Real-time chat and notifications
- Adaptive layouts for different devices

## Key Features
- **Flutter Web Support:**
  - Run `flutter build web` to deploy as a PWA or web app
  - Responsive widgets and layouts in `lib/`
- **Dynamic Data:**
  - Uses GraphQL/REST APIs for real-time data
  - Supports push notifications and live updates
- **Admin Control:**
  - Admin can push settings, content, or feature toggles via backend
- **Extensibility:**
  - Add new WAP features by extending frontend/backend logic

## How to Use
- To run as a web app: `flutter run -d chrome` or `flutter build web`
- To enable new WAP features, update business logic in `frontend/lib/` and backend APIs

---
For more, see `frontend/LOGIC.md` and backend docs.
