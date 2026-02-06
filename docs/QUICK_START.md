# Sambad - Quick Start Guide

## Start Everything (3 commands)
```bash
# 1. PostgreSQL
brew services start postgresql@14

# 2. Backend (Terminal 1)
cd ~/Desktop/sambad/app_user/backend && npm start

# 3. Flutter (Terminal 2)
cd ~/Desktop/sambad/app_user/frontend && flutter run
```

## Check Status
```bash
# PostgreSQL running?
pg_isready

# Backend responding?
curl http://localhost:4000

# Database exists?
psql postgres -c "\l" | grep sambad_unified
```

## File Locations

- Backend config: `app_user/backend/src/db.ts`
- Flutter main: `app_user/frontend/lib/main.dart`
- Theme: `app_user/frontend/lib/theme/app_theme.dart`
- Login: `app_user/frontend/lib/screens/login_screen.dart`

## Current Ports

- PostgreSQL: 5432
- Backend: 4000
- Frontend: Uses 10.0.2.2:4000 (emulator)

## Version: 4.0.0 (85% Complete)
