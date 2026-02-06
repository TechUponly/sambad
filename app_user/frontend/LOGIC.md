## Login Page UI & Country Picker Logic (as of 2025-12-31)

- The login page now shows only a simple mobile number entry by default. OTP UI is hidden unless enabled by admin config.
- Country code picker is a small tab (default: India, +91), mobile number field is larger for better mobile UX.
- When a country is selected, the required mobile digit count is updated accordingly.
- The user must enter a mobile number matching the digit count for the selected country to proceed (login).
- If the entered number does not match, an error is shown and the user cannot proceed.
- All other login options (OTP, Google, Apple) are controlled by admin config and do not block entry if not enabled.

**Example:**

> User selects India (+91), enters: 987654321 (9 digits) → Error: "Enter a valid mobile number (10 digits) for +91"
> User selects US (+1), enters: 1234567890 (10 digits) → Error: "Enter a valid mobile number (11 digits) for +1"
> User selects India (+91), enters: 9876543210 (10 digits) → Allowed to proceed

# Tech Stack Implemented
_Flutter (Dart), Dio (networking, migrated from http for scalability), Node.js/TypeScript backend, PostgreSQL, GraphQL API._

# Sambad User App Logic Documentation

## Overview
This document describes the core logic and architecture of the Sambad user-facing Flutter application. It is intended for developers and administrators to understand, maintain, and extend the app.

---

## 1. App Structure
- **Frontend:** Flutter (Dart), located in `frontend/`
- **Backend:** Node.js/TypeScript GraphQL API, located in `sambad_backend/`

---

## 2. Core Features
- User authentication (JWT, via backend)
- Contacts management (add, search, list)
- One-to-one and group chat
- Auto-clearance of chat data on inactivity or app background
- End-to-end encryption ready (client-side)
- Image sharing

---

## 3. Chat Logic
- **Message Sending:**
  - Messages are sent via `ChatService.sendMessage()` and stored locally and synced to backend.
  - Supports text and image messages.
- **Message Display:**
  - Messages are decrypted and displayed in chat pages using `MessageBubble` widgets.
- **Auto-Clearance:**
  - Inactivity timer (default 5 min) clears all messages if user is idle.
  - Private messages are purged after 30 minutes or when session is inactive.
  - App lifecycle events (background, pause) also trigger clearance.
- **Encryption:**
  - AES-GCM encryption for local message storage.
  - Decryption on message display.

---

## 4. Group & Contact Management
- Groups and contacts are managed via dialogs and stored locally, with sync to backend.
- Group chat uses a stable group ID derived from group name.

---

## 5. Integration with Backend
- All data operations (auth, contacts, messages) use GraphQL API in `sambad_backend/`.
- JWT authentication is required for all API calls.

---

## 6. Extensibility
- Add new features by extending `ChatService` and UI widgets.
- Backend schema can be updated in `sambad_backend/src/schema.graphql`.

---

## 7. Security
- All sensitive data is encrypted in transit (HTTPS) and at rest (AES-GCM).
- JWT for authentication.

---

## 8. References
- See `lib/services/chat_service.dart` for chat logic.
- See `lib/chat_page.dart` for chat UI and message handling.
- See `sambad_backend/README.md` for backend API details.

---

## 9. Business Logic (2025-12-31)

### 9.1 User Authentication & Login
- Only allow login with a valid 10-digit mobile number (or country-specific ID, as per config).
- OTP, Google, iOS, and Face Recognition login methods are present in code but only activated when enabled from the admin panel.
- After first successful login, biometric (face recognition) can be used if enabled by admin.

### 9.2 Privacy & Security
- User cannot take screenshots or use external camera/photo capture while in the app (enforced at platform level where possible).
- All chats and shared documents are super private and protected from external capture.

### 9.3 Chat Auto-Deletion
- Chats are automatically deleted within 30 minutes of being sent/received.
- If a chat is out of view (not on screen) for more than 5 minutes, it is purged from local storage.
- All chat data is deleted immediately upon user logout.
- These auto-deletion and privacy rules can be toggled on/off from the admin panel in the future.

### 9.4 Media & Document Sharing
- Users can:
  - Upload and share documents (PDF, DOCX, etc.)
  - Share existing pictures from device
  - Click photos using device camera and share
  - Record and share voice messages
- All shared media and documents are subject to the same auto-deletion rules as chat messages:
  - Auto-delete within 30 minutes
  - Delete if out of view for more than 5 minutes
  - Delete on logout
- Media and document sharing is protected by privacy rules (no external screenshot or capture allowed).

### 9.5 Privacy Policy & User Consent
- On first login, users must review and accept the privacy policy in the app settings.
- The privacy policy clearly explains all admin access and control (microphone, camera, location, chat, media, etc.).
- Explicit user consent is required for each type of access before enabling related features.
- Consent status is stored securely and can be reviewed or revoked by the user in settings at any time.
- Admin access and control is only granted for permissions the user has accepted.

---

For further details, contact the project maintainer or see the code comments in each file.
