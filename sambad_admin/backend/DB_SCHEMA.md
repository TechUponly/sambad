# Admin App Database & Integration Schema (for Real-Time Control)

## Overview
The admin backend is designed to:
- Monitor and control user app data in real time
- Manage admin-specific data (roles, logs, settings)
- Integrate with the user app backend via direct DB access or API

## User App Integration
- The admin backend can connect to the user app database (see `app_user/backend/DB_SCHEMA.md`) for real-time reads/writes.
- Alternatively, use GraphQL/REST APIs for secure, decoupled integration.

## Admin-Specific Tables

### admin_users
- id (PK, UUID)
- username (string, unique)
- password_hash (string)
- email (string, unique)
- role (enum: superadmin, moderator, etc.)
- created_at (timestamp)
- updated_at (timestamp)

### admin_logs
- id (PK, UUID)
- admin_user_id (FK to admin_users.id)
- action (string)
- target_type (string: user, group, message, etc.)
- target_id (UUID)
- timestamp (timestamp)
- details (jsonb)

### settings
- id (PK, UUID)
- key (string, unique)
- value (jsonb)
- updated_at (timestamp)

## Real-Time Data Flow
- Use DB triggers, pub/sub, or API webhooks to sync changes between user and admin backends.
- Admin actions (e.g., block user, delete message) are instantly reflected in the user app.

## Security
- All admin actions are logged in `admin_logs`.
- Use RBAC (role-based access control) for admin users.

---
For implementation, see backend ORM models and GraphQL schema. For integration, see user app DB schema and API docs.
