# Sambad - Clean Architecture Documentation

## Overview
Sambad is a secure messaging application with unified database architecture.

**Version**: 4.0.0  
**Last Updated**: January 24, 2026  
**Status**: 85% Production Ready

---

## System Architecture
```
sambad/
├── app_user/                    # User-facing application
│   ├── frontend/               # Flutter mobile app
│   └── backend/                # Express.js API (Port 4000)
│
├── sambad_admin/               # Admin dashboard
│   ├── frontend/               # Admin web panel
│   └── backend/                # Admin API
│
└── Database: sambad_unified    # PostgreSQL unified database
```

---

## Database Architecture

### PostgreSQL Setup
- **Host**: localhost:5432
- **Database**: `sambad_unified` (unified database for both user & admin)
- **User**: shamrai
- **ORM**: TypeORM with auto-sync enabled

### Tables
- `users` - User accounts
- `contacts` - User connections
- `messages` - Chat messages
- `groups` - Group chats
- `group_members` - Group memberships
- `admin_users` - Admin accounts
- `admin_audit_logs` - Admin actions
- `settings` - System settings

**Note**: Both user and admin backends connect to the SAME database.

---

## Backend Configuration

### User Backend
- **Port**: 4000
- **Database**: sambad_unified
- **Entry**: src/index.ts
- **Config**: src/db.ts

### Key Files - DO NOT MODIFY BUSINESS LOGIC
```
app_user/backend/
├── src/
│   ├── index.ts              # Main server
│   ├── db.ts                 # Database config
│   ├── models/               # Entities (DO NOT MODIFY)
│   ├── routes/               # API endpoints (DO NOT MODIFY)
│   └── middleware/           # Auth (DO NOT MODIFY)
```

---

## Frontend Configuration

### User App
- **Framework**: Flutter
- **Backend URL**: http://10.0.2.2:4000
- **Theme**: Blue (#5B7FFF)

### Key Files - DO NOT MODIFY BUSINESS LOGIC
```
app_user/frontend/
├── lib/
│   ├── main.dart
│   ├── home_page.dart
│   ├── services/             # Business logic (DO NOT MODIFY)
│   └── theme/
```

---

## Running the Application
```bash
# 1. Start PostgreSQL
brew services start postgresql@14

# 2. Start Backend
cd ~/Desktop/sambad/app_user/backend
npm start

# 3. Start Flutter
cd ~/Desktop/sambad/app_user/frontend
flutter run
```

---

## Files to Clean Up (Can Delete)
```
app_user/backend/src/*.incomplete
app_user/backend/src/*.no-posts
app_user/backend/src/*.before-flutter-fix
app_user/backend/sambad_user.db (old SQLite)
sambad_admin/backend/admin.db (old SQLite)
```

---

## Current Status: v4.0.0

✅ Frontend UI: 95%
✅ Backend: 90%
✅ Database: 85%
⏳ API Endpoints: 60%
⏳ Live Chat: 50%

**Overall: 85% Complete**
