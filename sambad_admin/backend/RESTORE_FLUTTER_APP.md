# Restore Flutter Admin App

## Issue
The HTML test dashboard was being served at the root path, which interfered with the Flutter app.

## Fix Applied
✅ Moved HTML dashboard to `/test-dashboard` path  
✅ Admin backend REST API still running on port 5050

## Two Separate Systems

### 1. **Admin Backend REST API** (Port 5050)
- **Purpose:** REST API for admin operations
- **URL:** `http://localhost:5050`
- **Endpoints:** `/login`, `/analytics`, `/users`, `/messages`, `/contacts`
- **Test Dashboard:** `http://localhost:5050/test-dashboard` (HTML)

### 2. **Flutter Admin App** (Separate)
- **Purpose:** Full-featured Flutter admin dashboard
- **Connects to:** `http://localhost:4000/graphql` (User Backend GraphQL)
- **Location:** `sambad_admin/frontend/`
- **Features:**
  - Dashboard with charts
  - Users management
  - Analytics
  - Profile, Settings, Config
  - Rights management
  - Audit logs
  - Logout

## How to Run Flutter Admin App

### Option 1: Run in Chrome (Web)
```bash
cd /Users/shamrai/Desktop/sambad/sambad_admin/frontend
flutter run -d chrome
```

### Option 2: Run on macOS Desktop
```bash
cd /Users/shamrai/Desktop/sambad/sambad_admin/frontend
flutter run -d macos
```

### Option 3: Run on iOS Simulator
```bash
cd /Users/shamrai/Desktop/sambad/sambad_admin/frontend
flutter run -d ios
```

## Prerequisites

1. **User Backend must be running** (GraphQL on port 4000):
   ```bash
   cd /Users/shamrai/Desktop/sambad/app_user/backend/sambad_backend
   npm run dev
   ```

2. **Flutter dependencies installed**:
   ```bash
   cd /Users/shamrai/Desktop/sambad/sambad_admin/frontend
   flutter pub get
   ```

## Flutter App Login Credentials

Based on the code, the Flutter app uses SHA-256 hashed credentials:
- **Username:** `7718811069` (hashed)
- **Password:** `Taksh@060921` (hashed)

The login screen will accept these credentials.

## What You'll See in Flutter App

1. **Login Screen** - Sky blue theme
2. **Dashboard** - Main dashboard with:
   - Sidebar navigation
   - Dashboard content
   - Users section
   - Analytics
   - Profile, Settings, Config, Rights, Audit screens

## Current Status

✅ **Admin Backend REST API:** Running on port 5050  
✅ **HTML Test Dashboard:** Available at `/test-dashboard`  
✅ **Flutter App:** Ready to run (needs user backend on port 4000)

---

**The Flutter app is your main admin interface. The HTML dashboard is just a test tool.**
