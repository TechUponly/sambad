# Sambad Admin Backend Logic

## Overview
This backend provides admin control over both the user app and admin app. It exposes APIs for:
- Managing users, contacts, and messages
- Monitoring and controlling user app state
- Managing admin dashboard features

## Structure
- `sambad_admin/frontend/` — Admin dashboard Flutter/web app
- `sambad_admin/backend/` — Node.js/TypeScript backend for admin

## Key Features
- Admin authentication (JWT)
- User management (CRUD, block/unblock, audit)
- Contact and group management
- Message monitoring and moderation
- Settings and feature toggles for both apps
- APIs to control/monitor user app backend (via direct DB or API calls)

## Cross-App Control
- The admin backend can connect to the user backend DB or call its APIs for real-time control.
- Admin actions (e.g., block user, clear chat, push notification) are propagated to the user backend.

## Extensibility
- Add new admin features by extending GraphQL/REST endpoints.
- Integrate analytics, reporting, or automation as needed.

## References
- See `backend/` for code
- See `frontend/` for admin UI
- See user app backend for integration points

---
For further details, see code comments or contact the project maintainer.
