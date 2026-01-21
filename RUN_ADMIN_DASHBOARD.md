# Running Admin Dashboard (Flutter + Unified Backend)

## Quick Start

### 1. Start the Unified Backend Server

```bash
cd app_user/backend
npm run dev
```

The server will start on **port 4000** and you'll see:
```
✅ Unified backend listening on port 4000
🌐 Health: http://localhost:4000/
🔐 Admin Login: POST http://localhost:4000/api/admin/login
📊 Admin API: http://localhost:4000/api/admin/*
👤 User API: http://localhost:4000/api/*
```

### 2. Create an Admin User

In a new terminal:

```bash
cd app_user/backend
ts-node scripts/create-admin.ts admin admin123 admin@sambad.com superadmin
```

This creates:
- Username: `admin`
- Password: `admin123`
- Email: `admin@sambad.com`
- Role: `superadmin`

### 3. Run Flutter Admin Dashboard

In a new terminal:

```bash
cd sambad_admin/frontend
flutter run
```

Or for web:
```bash
flutter run -d chrome
```

Or for macOS:
```bash
flutter run -d macos
```

## Flutter App Configuration

The Flutter app is now configured to use:
- **Base URL:** `http://localhost:4000/api/admin`
- **REST API** (not GraphQL)
- **Authentication:** JWT Bearer tokens

### API Endpoints Used by Flutter:

- `POST /api/admin/login` - Admin login
- `GET /api/admin/analytics` - Dashboard analytics
- `GET /api/admin/activity` - Recent activity
- `GET /api/admin/users` - List all users
- `GET /api/admin/contacts` - List all contacts
- `GET /api/admin/messages` - List all messages

## Login Credentials

Use the credentials you created with the script:
- **Username:** `admin` (or the username you specified)
- **Password:** `admin123` (or the password you specified)

## Features

The Flutter admin dashboard shows:
- ✅ **Dashboard** - Analytics cards, charts, recent activity
- ✅ **Users** - List of all users
- ✅ **Analytics** - Growth metrics
- ✅ **Activity** - Real-time updates (via WebSocket)
- ✅ **Profile** - Admin profile
- ✅ **Settings** - App settings
- ✅ **Audit Log** - Admin actions log

## Troubleshooting

### Backend not starting?
- Check if port 4000 is already in use
- Verify PostgreSQL is running
- Check database connection settings in `.env` or `data-source.ts`

### Flutter can't connect?
- Make sure backend is running on port 4000
- Check CORS settings (should be enabled)
- For mobile/emulator, use `10.0.2.2` instead of `localhost` on Android
- For iOS simulator, `localhost` works fine

### Login fails?
- Make sure admin user exists (run create-admin script)
- Check password is correct
- Verify JWT secret is set (defaults to 'dev-admin-secret')

## Architecture

```
┌─────────────────────┐
│  Flutter Admin App  │
│  (sambad_admin)     │
└──────────┬──────────┘
           │ REST API
           │ (port 4000)
           ▼
┌─────────────────────┐
│  Unified Backend    │
│  (Express/Node.js)  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  PostgreSQL         │
│  sambad_user DB     │
└─────────────────────┘
```

All data is now in one place - the unified backend and database!
