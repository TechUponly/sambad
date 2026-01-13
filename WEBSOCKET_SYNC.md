## 2025-12-31: Flutter Admin Dashboard WebSocket Client

- Integrated `web_socket_channel` in `sambad_admin/frontend`.
- Created `websocket_service.dart` singleton for connection management.
- Dashboard connects to backend WebSocket on load and listens for `contact_added` and `message_sent` events.
- UI updates instantly with new activity as soon as user actions occur (no polling required).
- All code and logic changes are tracked in this file and `sambad.md`.
# WebSocket Real-Time Sync Integration (2025-12-31)

## Overview
This document tracks the implementation of true real-time sync between the Sambad user app and admin dashboard using WebSockets.

---

## Why WebSocket?
- Enables instant, bidirectional communication between backend and admin dashboard.
- Admin dashboard receives updates (new messages, contacts, analytics) as soon as user actions occur, without polling.

---

## Implementation Plan

### 1. Backend (Node.js/TypeScript)
- Add WebSocket server (e.g., using `ws` or `socket.io`).
- Emit events to all connected admin dashboards on user actions (message sent, contact added, etc.).
- Update REST/GraphQL endpoints to also trigger WebSocket events.

### 2. Admin Dashboard (Flutter)
- Add WebSocket client (e.g., using `web_socket_channel` package).
- Listen for backend events and update UI instantly (users, activity, analytics, etc.).
- Fallback to polling if WebSocket is unavailable.

### 3. User App (Flutter)
- No direct WebSocket needed; continue to push events to backend via REST as before.

---

## Migration Notes
- This upgrade replaces polling-based "real-time" with true push-based updates for admin.
- All changes are documented in `sambad.md` and this file.

---

## References
- See `backend/src/index.ts` for WebSocket server setup.
- See `sambad_admin/frontend/lib/services/` for WebSocket client integration.
- See `sambad.md` for overall architecture and migration history.

---

For further details, see code comments and per-app logic docs.
