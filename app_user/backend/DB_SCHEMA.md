# Sambad Unified Database Schema (Contract)

## Overview
This document defines the authoritative database schema contract for the Sambad unified application. The schema supports real-time chat, contact management, group operations, admin control, and monitoring - all in a **single unified database** with **role-based access control**.

**Architecture:** Unified Database + Role-Based Access Control (RBAC)

**Design Principles (Sales Management OS Core Aligned):**
- ✅ Explicit intent over implicit behavior
- ✅ Strict separation of concerns per table
- ✅ Event-driven architecture support
- ✅ Auditability and traceability
- ✅ Contract-based design (immutable schema definition)
- ✅ Single source of truth (unified database)
- ✅ Role-based access, not separate systems

---

## Tables

### users
**Purpose:** Core user identity and authentication data.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique user identifier |
| username | VARCHAR | UNIQUE, NOT NULL | User's unique username |
| email | VARCHAR | UNIQUE, NOT NULL | User's email address |
| password_hash | VARCHAR | NOT NULL | Hashed password (bcrypt) |
| created_at | TIMESTAMP | NOT NULL | Account creation timestamp |
| updated_at | TIMESTAMP | NOT NULL | Last update timestamp |

**Relations:**
- One-to-many with `contacts` (as `user_id`)
- One-to-many with `contacts` (as `contact_user_id`)
- One-to-many with `groups` (as `created_by`)
- One-to-many with `group_members` (as `user_id`)
- One-to-many with `messages` (as `from_user_id`)
- One-to-many with `messages` (as `to_user_id`)

---

### contacts
**Purpose:** User-to-user contact relationships (bidirectional).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique contact relationship identifier |
| user_id | UUID | FOREIGN KEY (users.id), NOT NULL | Owner of the contact |
| contact_user_id | UUID | FOREIGN KEY (users.id), NOT NULL | The user being added as contact |
| created_at | TIMESTAMP | NOT NULL | Contact creation timestamp |

**Constraints:**
- Unique constraint on (`user_id`, `contact_user_id`) recommended to prevent duplicates
- `user_id` ≠ `contact_user_id` (self-contacts not allowed)

**Relations:**
- Many-to-one with `users` (as `user_id`)
- Many-to-one with `users` (as `contact_user_id`)

---

### groups
**Purpose:** Group/chat room entities.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique group identifier |
| name | VARCHAR | NOT NULL | Group display name |
| created_by | UUID | FOREIGN KEY (users.id), NOT NULL | User who created the group |
| created_at | TIMESTAMP | NOT NULL | Group creation timestamp |

**Relations:**
- Many-to-one with `users` (as `created_by`)
- One-to-many with `group_members` (as `group_id`)
- One-to-many with `messages` (as `group_id`)

---

### group_members
**Purpose:** User membership in groups (junction table).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique membership identifier |
| group_id | UUID | FOREIGN KEY (groups.id), NOT NULL | Group identifier |
| user_id | UUID | FOREIGN KEY (users.id), NOT NULL | Member user identifier |
| joined_at | TIMESTAMP | NOT NULL | Membership creation timestamp |

**Constraints:**
- Unique constraint on (`group_id`, `user_id`) recommended to prevent duplicate memberships

**Relations:**
- Many-to-one with `groups` (as `group_id`)
- Many-to-one with `users` (as `user_id`)

---

### messages
**Purpose:** Chat messages (one-to-one and group messages).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique message identifier |
| from_user_id | UUID | FOREIGN KEY (users.id), NOT NULL | Message sender |
| to_user_id | UUID | FOREIGN KEY (users.id), NULLABLE | Recipient user (for one-to-one messages) |
| group_id | UUID | FOREIGN KEY (groups.id), NULLABLE | Group identifier (for group messages) |
| content | TEXT | NOT NULL | Message content |
| type | VARCHAR | NOT NULL, DEFAULT 'text' | Message type (e.g., 'text', 'image', 'document', 'voice') |
| created_at | TIMESTAMP | NOT NULL | Message creation timestamp |
| is_deleted | BOOLEAN | NOT NULL, DEFAULT FALSE | Soft delete flag |

**Constraints:**
- Exactly one of (`to_user_id`, `group_id`) must be set (mutually exclusive)
- `to_user_id` IS NOT NULL XOR `group_id` IS NOT NULL

**Relations:**
- Many-to-one with `users` (as `from_user_id`)
- Many-to-one with `users` (as `to_user_id`, nullable)
- Many-to-one with `groups` (as `group_id`, nullable)

---

## Real-Time Sync Architecture

**Event-Driven Design:**
- Use database triggers or pub/sub (PostgreSQL NOTIFY/LISTEN, Redis) to emit events on data changes
- Events: `message_created`, `contact_added`, `group_created`, `group_member_added`, `user_updated`
- Backend services subscribe to events for real-time WebSocket broadcasts
- Admin backend can subscribe to all events for monitoring and moderation

**Implementation Notes:**
- Backend WebSocket server emits events to connected clients (user app, admin dashboard)
- Events include: entity type, action (CREATE/UPDATE/DELETE), entity ID, and relevant data
- Both user and admin backends can subscribe to these events for real-time updates

---

## Admin Control & Monitoring

**Access Pattern:**
- Admin backend has read/write access to all tables for moderation, analytics, and user management
- All admin actions should be logged in an audit log (see admin data model)
- Changes made by admin are reflected in real-time to user app via API or WebSocket events

**Auditability:**
- All state changes are event-driven and traceable
- Timestamps on all entities support audit trails
- Soft delete pattern (`is_deleted` flag) preserves history

---

## Implementation Details

**ORM Mapping:**
- TypeORM entities map to these tables (see `src/models/` directory)
- Column names in database follow TypeORM naming strategy (default: camelCase, e.g., `fromUserId`)
- Entity properties use relation names (e.g., `from_user`, `to_user`) which map to FK columns

**Migration Strategy:**
- Schema changes require database migrations
- All migrations must preserve data integrity and backward compatibility
- See `src/data-source.ts` for TypeORM configuration

---

## Contract Compliance

This schema follows Sales Management OS Core principles:
- **Explicit Contracts:** Clear table definitions with explicit constraints
- **Separation of Concerns:** Each table has a single, well-defined responsibility
- **Event-Driven:** Supports real-time sync via event emission
- **Auditability:** Timestamps and soft-delete patterns enable audit trails
- **Immutable Definition:** Schema changes require explicit migrations and documentation

---

---

## Admin Tables (Unified Database)

The following admin tables are also stored in the same database:

### admin_users
**Purpose:** Admin user accounts for dashboard access.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique admin identifier |
| username | VARCHAR | UNIQUE, NOT NULL | Admin username |
| email | VARCHAR | UNIQUE, NOT NULL | Admin email |
| password_hash | VARCHAR | NOT NULL | Hashed password (bcrypt) |
| role | VARCHAR | NOT NULL, DEFAULT 'moderator' | Admin role (superadmin, admin, moderator, viewer) |
| created_at | TIMESTAMP | NOT NULL | Account creation timestamp |
| updated_at | TIMESTAMP | NOT NULL | Last update timestamp |

### admin_logs
**Purpose:** Audit log for admin actions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique log identifier |
| admin_user_id | UUID | FOREIGN KEY (admin_users.id), NULLABLE | Admin who performed action |
| action | VARCHAR | NOT NULL | Action type (e.g., 'LOGIN', 'DELETE_USER') |
| target_type | VARCHAR | NOT NULL | Target entity type |
| target_id | VARCHAR | NOT NULL | Target entity ID |
| timestamp | TIMESTAMP | NOT NULL | Action timestamp |
| details | JSONB | NULLABLE | Additional action details |

### settings
**Purpose:** Application settings and configuration.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique setting identifier |
| key | VARCHAR | UNIQUE, NOT NULL | Setting key |
| value | JSONB | NOT NULL | Setting value (JSON) |
| updated_at | TIMESTAMP | NOT NULL | Last update timestamp |

---

For implementation details, see:
- TypeORM models: `src/models/`
- Data source configuration: `src/data-source.ts`
- Unified server: `src/index.ts`
- Architecture: `ARCHITECTURE_DECISION.md`
