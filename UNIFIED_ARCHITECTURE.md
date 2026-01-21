# Unified Architecture Implementation

## Status: ✅ COMPLETE

Date: 2025-01-15

## Summary

Successfully unified the Sambad architecture from **two separate servers and databases** to a **single server and single database**.

## What Changed

### Before
- **Two servers:**
  - User backend (port 4000)
  - Admin backend (port 5050)
- **Multiple databases:**
  - PostgreSQL `sambad_user` (user data)
  - PostgreSQL `sambad_admin` (admin data)
  - SQLite `sambad.db` (admin was reading from this)

### After
- **Single server:**
  - Unified Express server (port 4000)
  - All routes in one codebase
- **Single database:**
  - PostgreSQL `sambad_user` (all data)
  - All entities in one database

## Architecture

```
┌─────────────────────────────────────┐
│   Unified Express Server :4000       │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  Admin Routes                  │ │
│  │  /api/admin/login             │ │
│  │  /api/admin/analytics         │ │
│  │  /api/admin/activity          │ │
│  │  /api/admin/users             │ │
│  │  /api/admin/messages          │ │
│  │  /api/admin/contacts          │ │
│  │  (Requires: JWT auth + role)  │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  User Routes                   │ │
│  │  /api/users                   │ │
│  │  /api/contacts                │ │
│  │  /api/messages                │ │
│  │  (Public endpoints)           │ │
│  └───────────────────────────────┘ │
└──────────────┬──────────────────────┘
               │
               ▼
        ┌──────────────┐
        │  PostgreSQL  │
        │  sambad_user │
        │              │
        │  - users     │
        │  - contacts  │
        │  - groups    │
        │  - group_members│
        │  - messages  │
        │  - admin_users│
        │  - admin_logs│
        │  - settings  │
        └──────────────┘
```

## Files Changed

### Added
- `app_user/backend/src/models/admin_user.ts`
- `app_user/backend/src/models/admin_log.ts`
- `app_user/backend/src/models/setting.ts`
- `app_user/backend/src/middleware/auth.ts`

### Modified
- `app_user/backend/src/data-source.ts` - Added admin entities
- `app_user/backend/src/index.ts` - Unified server with all routes
- `app_user/backend/package.json` - Added auth dependencies

### Dependencies Added
- `bcryptjs` - Password hashing
- `jsonwebtoken` - JWT authentication
- `cors` - CORS support
- `dotenv` - Environment variables
- `@types/bcryptjs`, `@types/jsonwebtoken`, `@types/cors` - TypeScript types

## API Endpoints

### Admin Endpoints (Requires Authentication)

All admin endpoints require a JWT token in the `Authorization: Bearer <token>` header.

- `POST /api/admin/login` - Admin login (public)
- `GET /api/admin/analytics` - Get analytics (admin/moderator)
- `GET /api/admin/activity` - Get recent activity (admin/moderator)
- `GET /api/admin/users` - List all users (admin/moderator/viewer)
- `GET /api/admin/messages` - List all messages (admin/moderator)
- `GET /api/admin/contacts` - List all contacts (admin/moderator)

### User Endpoints (Public)

- `GET /api/users` - List all users
- `GET /api/contacts` - List all contacts
- `GET /api/messages` - List all messages

## Database Configuration

The unified database uses:
- **Type:** PostgreSQL
- **Database:** `sambad_user` (configurable via `DB_NAME` env var)
- **Naming Strategy:** Snake case (e.g., `user_id`, `created_at`)
- **Entities:** All user and admin entities in one database

## Environment Variables

```bash
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_NAME=sambad_user

# Server
PORT=4000

# Admin Auth
ADMIN_JWT_SECRET=your-secret-key
```

## Migration Notes

### For Admin Dashboard

Update the admin frontend to use:
- Base URL: `http://localhost:4000`
- Login endpoint: `POST /api/admin/login`
- All admin endpoints: `/api/admin/*`

### For User App

No changes needed - user endpoints remain at `/api/*`.

## Benefits

1. **Simplified Deployment** - One server to deploy and monitor
2. **Single Source of Truth** - All data in one database
3. **Easier Maintenance** - One codebase to update
4. **Better Resource Usage** - Single connection pool
5. **Consistent Error Handling** - Unified middleware
6. **Role-Based Security** - Clear separation via middleware

## Next Steps

1. Update admin frontend to use new endpoints
2. Remove old admin backend server code (optional cleanup)
3. Set up environment variables in production
4. Configure database migrations for admin tables
