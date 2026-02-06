# Admin Backend Configuration & Role Management

## Overview
This document describes how to configure admin roles, permissions, and operational access for the Sambad admin backend.

---

## 1. Roles & Permissions
- **admin_users** table includes a `role` field (e.g., superadmin, moderator, operator, viewer)
- Each role has a set of permissions (CRUD, audit, manage users, etc.)
- Permissions can be extended in code or via a `settings` table

### Example Roles
- **superadmin**: Full access to all features and settings
- **moderator**: Manage users, messages, groups, but not system settings
- **operator**: Limited to operational tasks (e.g., monitoring, reporting)
- **viewer**: Read-only access

---

## 2. Configuring Rights
- Use the `settings` table to store custom permissions or feature toggles
- Add or update admin users in the `admin_users` table with the desired role
- Extend backend logic to check role/permission before each operation

---

## 3. Usage for Operations Team
- Operators can be given access to specific dashboards or API endpoints
- Rights can be changed by a superadmin via the admin UI or direct DB update
- All actions are logged in `admin_logs` for audit

---

## 4. Extensibility
- Add new roles or permissions by updating the `role` enum and backend logic
- Use the `settings` table for feature flags or operational controls

---

## References
- See `src/models/admin_user.ts` for user/role model
- See `src/models/setting.ts` for config storage
- See `src/models/admin_log.ts` for audit logging

For implementation, update backend resolvers/controllers to enforce role-based access control (RBAC).
