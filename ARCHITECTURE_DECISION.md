# Architecture Decision: Unified Server & Database

## Decision Date
2026-01-15

## Status
✅ IMPLEMENTED

## Context
Initial implementation had:
- **Two separate servers:**
  - User backend (GraphQL, port 4000)
  - Admin backend (REST API, port 5050)
- **Two separate databases:**
  - `sambad.db` (user data)
  - `admin.db` (admin data, though admin backend was reading from sambad.db)

## Problem Statement
Having two servers and two databases creates:
1. **Unnecessary complexity** - Two codebases to maintain
2. **Data inconsistency risk** - Data split across systems
3. **Deployment overhead** - Two services to deploy and monitor
4. **Resource waste** - Duplicate connection pools, middleware, etc.
5. **Maintenance burden** - Changes need to be made in two places

## Decision
**Consolidate to unified architecture:**
- **One server:** GraphQL server (port 4000)
- **One database:** `sambad.db` (all data)
- **Role-based access control:** Segregation via GraphQL resolvers

## Architecture

```
┌─────────────────────────────────────┐
│   Unified GraphQL Server :4000      │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  User Operations               │ │
│  │  - createContactChannel        │ │
│  │  - contactChannels             │ │
│  │  (Requires: user auth)         │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  Admin Operations              │ │
│  │  - adminLogin                  │ │
│  │  - adminUsers                  │ │
│  │  - adminAnalytics              │ │
│  │  - adminActivity               │ │
│  │  - adminContacts               │ │
│  │  (Requires: admin role)        │ │
│  └───────────────────────────────┘ │
└──────────────┬──────────────────────┘
               │
               ▼
        ┌──────────────┐
        │  sambad.db   │
        │              │
        │  - users     │
        │  - admin_users│
        │  - contact_channels│
        │  - user_events│
        │  - admin_audit_logs│
        │  - ...       │
        └──────────────┘
```

## Role-Based Access Control

### User Role
- Can create/view own contacts
- Can access own data
- Limited to user-scoped operations

### Admin Role
- Can view all users
- Can view analytics
- Can view all contacts
- Can view activity logs
- Enforced in GraphQL resolvers via `context.user.role`

## Implementation

### GraphQL Schema
```graphql
type Query {
  # User queries
  contactChannels(userId: String): [ContactChannel!]!
  
  # Admin queries (role-checked in resolver)
  adminUsers: [User!]!
  adminAnalytics: Analytics!
  adminActivity: [Activity!]!
  adminContacts: [ContactChannel!]!
}

type Mutation {
  # Admin auth
  adminLogin(username: String!, password: String!): AdminAuthResponse!
  
  # User operations
  createContactChannel(userId: String!, channel: String!, address: String!): ContactChannel!
}
```

### Resolver Pattern
```typescript
adminUsers: async (_: any, __: any, context: any) => {
  // Role check
  if (!hasRole(context, ['superadmin', 'admin', 'moderator', 'viewer'])) {
    throw new Error('Unauthorized: Admin access required');
  }
  // ... fetch users
}
```

## Benefits

1. **Simplified Architecture**
   - Single codebase to maintain
   - Single deployment target
   - Single monitoring point

2. **Data Consistency**
   - All data in one database
   - No sync issues between systems
   - Single source of truth

3. **Better Resource Utilization**
   - One connection pool
   - Shared middleware
   - Reduced memory footprint

4. **Easier Development**
   - Changes in one place
   - Consistent error handling
   - Unified logging

5. **Role-Based Security**
   - Clear separation via resolvers
   - Easy to audit access
   - Flexible permission model

## Migration Path

1. ✅ Added admin resolvers to unified GraphQL server
2. ✅ Updated admin frontend to use GraphQL
3. ✅ Consolidated database (admin_users in sambad.db)
4. ✅ Removed separate admin backend server
5. ✅ Updated documentation

## Implementation Status (2025-01-15)

**COMPLETED:**
- ✅ Merged admin models (AdminUser, AdminLog, Setting) into user backend
- ✅ Unified authentication middleware using single data source
- ✅ Consolidated all routes into single Express server (port 4000)
- ✅ Single PostgreSQL database (`sambad_user`) for all data
- ✅ Role-based access control via middleware
- ✅ Admin routes: `/api/admin/*` (requires authentication)
- ✅ User routes: `/api/*` (public)

**Architecture:**
- **Single Server:** Express server on port 4000
- **Single Database:** PostgreSQL `sambad_user` database
- **All Entities:** users, contacts, groups, group_members, messages, admin_users, admin_logs, settings

## Lessons Learned

**What should have been done initially:**
1. **Architecture review** before implementation
2. **Identify single database/server pattern** upfront
3. **Design role-based access** from the start
4. **Avoid premature separation** of concerns

**CTO Best Practices:**
- Always question: "Do we need separate services/databases?"
- Start with simplest architecture, split only when necessary
- Use role-based access control, not separate systems
- One database = one source of truth

## References
- Sales Management OS Core Principles
- Single Responsibility Principle (applied at resolver level, not system level)
- Principle of Least Complexity
