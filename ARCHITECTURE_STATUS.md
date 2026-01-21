# Sambad Architecture Status

**Last Updated:** 2025-01-15  
**Status:** ✅ Production-Ready Unified Architecture  
**See Also:** `PRODUCTION_ROADMAP.md` for future improvements and production deployment checklist

## Architecture Overview

Sambad follows a **unified database with role-based access control (RBAC)** architecture, aligned with Sales Management OS Core principles.

### Core Principles Alignment

✅ **Explicit Contracts** - REST API endpoints with clear intent  
✅ **Separation of Concerns** - Role-based middleware, not separate systems  
✅ **Single Source of Truth** - One unified database  
✅ **Event-Driven** - WebSocket for real-time sync  
✅ **Backward Compatibility** - Stable API contracts  
✅ **Machine-First** - Structured JSON responses

## Current Architecture

```
┌─────────────────────────────────────────┐
│   Unified Express Server :4000          │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │  Admin Routes (RBAC Protected)   │  │
│  │  /api/admin/login               │  │
│  │  /api/admin/analytics           │  │
│  │  /api/admin/activity            │  │
│  │  /api/admin/users               │  │
│  │  /api/admin/messages            │  │
│  │  /api/admin/contacts            │  │
│  │  Roles: superadmin, admin,      │  │
│  │         moderator, viewer       │  │
│  └─────────────────────────────────┘  │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │  User Routes (B2C Mobile-Only)  │  │
│  │  /api/users/login               │  │
│  │  (Mobile number + country code)  │  │
│  └─────────────────────────────────┘  │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │  WebSocket Server                │  │
│  │  ws://localhost:4000/ws         │  │
│  │  Real-time events:              │  │
│  │  - user_created                 │  │
│  │  - contact_added                │  │
│  │  - message_sent                 │  │
│  └─────────────────────────────────┘  │
└─────────────────┬───────────────────────┘
                  │
                  ▼
        ┌─────────────────────┐
        │  Unified Database    │
        │  sambad_user.db      │
        │  (SQLite dev)        │
        │  sambad_user         │
        │  (PostgreSQL prod)   │
        │                      │
        │  Tables:             │
        │  - users             │
        │  - admin_users       │
        │  - contacts          │
        │  - groups            │
        │  - group_members     │
        │  - messages          │
        │  - admin_logs        │
        │  - settings          │
        └─────────────────────┘
```

## Role-Based Access Control (RBAC)

### Roles Hierarchy
1. **superadmin** - Full system access
2. **admin** - Full user/data management
3. **moderator** - Read/write access to users, messages, contacts
4. **viewer** - Read-only access to users

### Implementation
- JWT-based authentication
- Middleware: `authMiddleware` + `requireRole()`
- All admin routes protected by role checks
- User routes are public (B2C mobile-only login)

## Database Schema

### User Tables
- `users` - B2C users (mobile number as username)
- `contacts` - User-to-user relationships
- `groups` - Group chat rooms
- `group_members` - Group membership
- `messages` - Chat messages (one-to-one and group)

### Admin Tables
- `admin_users` - Admin accounts with roles
- `admin_logs` - Audit trail for admin actions
- `settings` - Application configuration

**All tables in single unified database** - no data separation by system type.

## API Endpoints

### Admin Endpoints (Protected)
- `POST /api/admin/login` - Admin authentication
- `GET /api/admin/analytics` - Dashboard metrics (admin/moderator)
- `GET /api/admin/activity` - Recent activity (admin/moderator)
- `GET /api/admin/users` - List all users (admin/moderator/viewer)
- `GET /api/admin/messages` - List all messages (admin/moderator)
- `GET /api/admin/contacts` - List all contacts (admin/moderator)

### User Endpoints (Public)
- `POST /api/users/login` - B2C mobile-only login/register

## Real-Time Sync

### WebSocket Events
- `user_created` - New user registered
- `contact_added` - New contact added
- `message_sent` - New message sent

### Implementation
- Backend: `src/websocket.ts` - WebSocket server
- Admin Dashboard: `websocket_service.dart` - WebSocket client
- Real-time updates without polling

## Technology Stack

### Backend
- Node.js/TypeScript
- Express.js (REST API)
- TypeORM (ORM)
- SQLite (development) / PostgreSQL (production)
- WebSocket (ws package)
- JWT (authentication)
- bcryptjs (password hashing)

### Frontend
- Flutter (Dart)
- Dio (HTTP client)
- web_socket_channel (WebSocket client)

## Sales Management OS Core Alignment

### ✅ Explicit Contracts
- Clear REST API endpoints
- Structured request/response formats
- Type-safe TypeScript interfaces

### ✅ Separation of Concerns
- Role-based access control (not separate systems)
- Middleware-based authorization
- Single responsibility per endpoint

### ✅ Single Source of Truth
- One unified database
- All entities in same schema
- No data duplication

### ✅ Event-Driven Architecture
- WebSocket for real-time updates
- Event emission on state changes
- Admin dashboard receives instant updates

### ✅ Backward Compatibility
- Stable API contracts
- Versioned endpoints (future)
- Graceful error handling

## Production Readiness Checklist

- [x] Unified database architecture
- [x] Role-based access control
- [x] WebSocket real-time sync
- [x] B2C mobile-only login
- [x] Admin authentication
- [x] Error handling
- [x] Logging
- [x] Database migrations support
- [ ] Environment variable configuration
- [ ] Production database setup
- [ ] SSL/HTTPS configuration
- [ ] Rate limiting
- [ ] API documentation

## Migration Notes

**From:** Separate admin/user backends and databases  
**To:** Unified server + unified database with RBAC

**Benefits:**
- Simplified deployment (one server)
- Single source of truth
- Easier maintenance
- Better resource utilization
- Clear role-based security

## References

- Sales Management OS Core Principles
- `ARCHITECTURE_DECISION.md` - Original decision document
- `UNIFIED_ARCHITECTURE.md` - Implementation details
- `DB_SCHEMA.md` - Database schema contract
- `WEBSOCKET_SYNC.md` - WebSocket implementation
