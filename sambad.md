## 2025-12-31: Real-Time WebSocket Sync

- WebSocket server added to backend (`src/websocket.ts`, integrated in `src/index.ts`).
- Backend emits events for contact/message changes to all connected admin dashboards.
- Admin dashboard (Flutter) connects via `web_socket_channel` and updates UI instantly on new events.
- All changes and rationale are tracked in `WEBSOCKET_SYNC.md`.

# Sambad Monorepo Documentation

---

## Tech Stack Implemented
_Flutter (Dart) for user and admin apps, Dio (networking, migrated from http for scalability), Node.js/TypeScript backend (Apollo Server, GraphQL), PostgreSQL (TypeORM), JWT authentication, HTTPS, security best practices._

---

## User App Logic (Frontend)
- Login page with country picker and mobile validation (admin-configurable login methods: OTP, Google, Apple, Face Recognition)
- Contacts management (add, search, list)
- One-to-one and group chat (auto-clearance, end-to-end encryption ready, AES-GCM for local storage)
- Image, document, and voice sharing (auto-deletion, privacy enforced)
- Privacy: screenshot/camera blocking, consent management, admin-controlled features
- All networking via Dio for robust, scalable API calls
- See `app_user/frontend/LOGIC.md` for full details and business rules

---

## Admin App Logic (Frontend)
- User/group management, feature toggles, audit logs, analytics, sub-admin rights, real-time controls, and theme management
- Admin can enable/disable login methods and privacy features for user app (synced in real time)
- Audit trail: all admin actions logged (feature toggles, user/group block/unblock, call/video access, etc.)
- Sub-admin management and rights assignment
- Real-time user device access (microphone, camera, location) with user consent
- Analytics dashboard with growth, activity, and filterable metrics
- Dark/light theme toggle, strict color/contrast rules for accessibility
- All networking via Dio for robust, scalable API calls
- See `sambad_admin/frontend/LOGIC.md` for full details and business rules

---

## Backend Logic (Admin & API)
- Node.js (TypeScript), Apollo Server (GraphQL), PostgreSQL (TypeORM)
- User registration, login, JWT-based authentication
- Contacts, one-to-one and group chat, admin data model
- GraphQL API for all data access, REST endpoints for integration
- End-to-end encryption ready (client-side)
- Passwords hashed with bcrypt, HTTPS, input validation, JWT for all API requests
- Admin and sub-admin logic, RBAC, audit trails, real-time sync
- See `app_user/backend/sambad_backend/LOGIC.md` and `app_user/backend/sambad_backend/README.md` for setup, API, and business rules

---

## Migration Notes
- 2025-12-31: Migrated all networking from `http` to `dio` in both user and admin apps for scalability and advanced features. Documented in respective `ApiService` files and logic docs.

---

## Directory Structure
- `app_user/` — User-facing app (Flutter)
- `sambad_admin/` — Admin-facing app (Flutter)
- `app_user/backend/sambad_backend/` — Node.js/TypeScript backend
- See each app's `LOGIC.md` for detailed logic and business rules

---

## Change Log
- All major changes, migrations, and tech stack decisions are recorded here and in per-app `LOGIC.md` files

---

## References
- `app_user/frontend/LOGIC.md` — User app logic and business rules
- `sambad_admin/frontend/LOGIC.md` — Admin app logic and business rules
- `app_user/backend/sambad_backend/LOGIC.md` — Backend logic and API
- `app_user/backend/sambad_backend/README.md` — Backend setup and API summary

---

## PostgreSQL Credentials (Backend)
**Username:** postgres
**Password:** changeme

These credentials are used for the Sambad backend database connection. Update your environment variables or TypeORM config if you change them.

### How to create the role manually
1. Open terminal and run:
   ```sh
   psql -U <your_mac_user> -d postgres
   ```
2. In the psql prompt, run:
   ```sql
   CREATE ROLE postgres WITH LOGIN PASSWORD 'changeme';
   ALTER ROLE postgres CREATEDB;
   ```

**Security Note:** Change the password for production deployments and restrict access as needed.

---

For questions, contact the project maintainer.
