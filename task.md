# Private Samvad — Bug Tracker & Task List (Apr 9-11, 2026)

## Sprint 4: 16/16 Original Issues ✅ + Testing Gaps + Production E2E Verified ✅

---

## Session 1: Original 16 Issues (ALL FIXED ✅)

| # | Issue | Status | Fix |
|---|-------|--------|-----|
| 1 | Login takes 3-5 min | ✅ | Progress UI + HTTP timeout (15s) |
| 2 | Invalid phone chars | ✅ | digitsOnly filter + PhoneValidator |
| 3 | Random number login | ✅ | Anti-spam: reject same-digit & sequential |
| 4 | Phone not visible after login | ✅ | Phone in welcome banner |
| 5 | No contact-add confirmation | ✅ | Success animation |
| 6 | Group creation broken | ✅ | Backend group API (6 endpoints) |
| 7 | Invite friend no link | ✅ | Enhanced share text with features |
| 8 | Back nav causes logout | ✅ | PopScope + double-tap-to-exit |
| 9 | No country code picker | ✅ | Country code dialog |
| 10 | Stale data on new login | ✅ | Session reset |
| 11 | Duplicate notifications | ✅ | FCM dedup by messageId |
| 12 | Contact search broken | ✅ | userId param + timeout |
| 13 | No contact edit option | ✅ | Edit dialog + updateContact() |
| 14 | Data persists after deletion | ✅ | Full reset pipeline |
| 15 | Adding contact slow (~220s) | ✅ | HTTP timeouts |
| 16 | Group creation (same as #6) | ✅ | Backend group API |

---

## Session 2: Testing Gaps Found

| # | Issue | Severity | Status | Details |
|---|-------|----------|--------|---------|
| 17 | Button text invisible (dark mode) | 🔴 Critical | ✅ Fixed | Added elevatedButtonTheme with foregroundColor: Colors.white |
| 18 | Blocked contact disappears | 🔴 Critical | ✅ Fixed | Now shows "Blocked" label with greyed-out UI + disabled tap |
| 19 | Can't re-add blocked contact | 🟡 Medium | ✅ Fixed | Auto-unblocks when adding same phone again |
| 20 | Profile save stays on page | 🟡 Medium | ✅ Fixed | Navigator.pop() after 500ms delay |
| 21 | WebSocket 404 in production | 🔴 Critical | ✅ Fixed | Nginx WS config verified + tested — `wss://` connects & receives messages |
| 22 | Firebase Auth fails on emulator | 🟡 Medium | ℹ️ Expected | Emulators fail Play Integrity — use test phone numbers |
| 23 | Group tile — no menu options | 🔴 Critical | ✅ Fixed | PopupMenu: Info, Block/Unblock, Exit, Delete |
| 24 | No Group Info/Profile page | 🔴 Critical | ✅ Fixed | New GroupInfoPage with all management features |
| 25 | No edit group name/description | 🟡 Medium | ✅ Fixed | Admin can edit via PUT /api/groups/:id |
| 26 | No add/remove members UI | 🟡 Medium | ✅ Fixed | Admin add/remove from GroupInfoPage |
| 27 | No group admin role | 🟡 Medium | ✅ Fixed | Creator=admin, promote/demote via API |
| 28 | No exit group option | 🔴 Critical | ✅ Fixed | POST /api/groups/:id/exit + auto-promote |
| 29 | No mute/block group | 🟡 Medium | ✅ Fixed | Block/unblock from group tile menu |
| 30 | Group messages — no sender name | 🟡 Medium | ✅ Fixed | API sends fromName in group_message broadcast |
| 31 | Group model missing description | 🟡 Medium | ✅ Fixed | Added description + role column to DB |
| 32 | Welcome banner shows phone not name | 🟡 Medium | ✅ Fixed | Shows "Welcome back, sham!" when profile name saved |
| 33 | Group Info — no photo or tap-to-rename | 🟡 Medium | ✅ Fixed | Photo picker + display on create & info page |
| 34 | No "Add Members" after group created | 🔴 Critical | ✅ Fixed | Auto-resolves server ID from ChatService, falls back to local data |
| 35 | Feedback not sent | 🟡 Medium | ✅ Fixed | POST /api/feedback → 201 Created, GET /api/admin/feedback → 200 OK |
| 36 | Light mode not working | 🟡 Medium | ✅ Fixed | Replaced hardcoded dark colors with AppColors.of(context) theme-aware |
| 37 | Online/offline status not working | 🟡 Medium | ✅ Fixed | E2E verified: user_online/user_offline broadcasts work, GET /api/users/:id/status returns online=true |
| 38 | Samvad AI tab fully empty | 🔴 Critical | `[ ]` Open | AI bot tab shows nothing — no chat UI, no input, no functionality |

---

## Session 3: Apr 10 Fixes

| # | Issue | Severity | Status | Details |
|---|-------|----------|--------|---------|
| 39 | ScreenProtector blocks text input on emulator | 🔴 Critical | ✅ Fixed | `protectDataLeakageOn()` disabled in debug mode via `kReleaseMode` check |
| 40 | Bottom nav dark in light mode | 🟡 Medium | ✅ Fixed | Replaced `Colors.black87` with `AppColors.of(context).card` |
| 41 | Admin features hidden (no camera, no add member) | 🔴 Critical | ✅ Fixed | `_currentUserId` now loaded from prefs + Firebase UID fallback |
| 42 | Group admin userId mismatch after fallback | 🟡 Medium | `[/]` In Progress | Roles saved at creation may use different userId than fallback Firebase UID |
| 43 | "Members" text cut off in GroupInfoPage | 🟡 Medium | `[ ]` Open | Left padding needed on group info page |

---

## Group Feature Checklist (#23-31)

### Backend
- `[x]` Add `description` and `icon` columns to Group model
- `[x]` Add `role` column to GroupMember model (admin/member)
- `[x]` PUT /api/groups/:id — edit group name/description
- `[x]` DELETE /api/groups/:id — delete group (admin only)
- `[x]` Make creator auto-admin in POST /api/groups

### Frontend — Group Info Page (NEW)
- `[x]` Group info/profile page with name, description, member list
- `[x]` Edit group name (admin only)
- `[x]` Edit group description (admin only)
- `[x]` Add member button (admin only)
- `[x]` Remove member (admin only)
- `[x]` Promote/demote admin (admin only)
- `[x]` Exit group button
- `[x]` Delete group button (admin only)

### Frontend — Group Tile Menu
- `[x]` PopupMenuButton on group tiles (like contacts)
- `[x]` "Group Info" option → opens group info page
- `[x]` "Block/Unblock" option → block/unblock group
- `[x]` "Exit Group" option
- `[x]` "Delete Group" option (admin only)

### Frontend — Group Chat
- `[x]` Backend sends sender name in group_message broadcast
- `[x]` Show member count in group tile subtitle

---

## ✅ Production E2E Test — 35/35 PASSED (Apr 11, 2026)

Full end-to-end test against `web.uponlytech.com/sambad-backend` with Firebase Auth.

| Category | Tests | Status | Details |
|----------|-------|--------|---------|
| Health & DB | 2/2 | ✅ | Backend healthy, DB connected |
| User Login | 2/2 | ✅ | Phone normalization, user creation |
| WebSocket | 3/3 | ✅ | Both users connect, receive welcome |
| 1:1 Messaging | 4/4 | ✅ | A→B real-time delivery, content verified |
| Reply Messages | 2/2 | ✅ | B→A bidirectional via WebSocket |
| Delivery Receipts | 4/4 | ✅ | Delivered + Read + sender notifications |
| Group Chat | 7/7 | ✅ | Create, add members, message, sender name |
| Group Management | 4/4 | ✅ | Rename, RBAC enforce, exit, notifications |
| Online Status | 2/2 | ✅ | User shows online, online list works |
| Feedback | 1/1 | ✅ | Submit + admin view |
| App Config | 1/1 | ✅ | Invite text fetched |
| Cleanup | 2/2 | ✅ | Group deleted, WS closed |

### Remaining Items

| Item | Status | Notes |
|------|--------|-------|
| Backend User ID Sync | ⚠️ | App may use Firebase UID as fallback; need to reconcile with backend userId on login |
| Admin Settings Sync | ⚠️ | `[AdminSync] 401` — admin backend auth token flow needs verification |
| Samvad AI Tab (#38) | `[ ]` | AI bot tab empty — feature not yet built |
| Members text cut (#43) | `[ ]` | Minor padding fix in GroupInfoPage |

---

## Commits Today

| Hash | Description |
|------|-------------|
| `4000cda` | Fix 8 critical bugs |
| `321a8df` | Chat delivery pipeline |
| `a254017` | Version bump 4.0.12+9 |
| `69d502e` | Signing key docs |
| `021280e` | Group API, phone validation, invite text |
| `19763e0` | Button text, blocked contact, profile nav, WS nginx |

---

## 🚀 Coming Soon — Samvad AI Document Analyzer

> Upload any document → Get instant AI analysis → Share or export → Auto-deletes in 24 hrs

### Features
- `[ ]` **Document Upload** — Upload PDF, DOC, TXT, images from device
- `[ ]` **AI Pros & Cons** — Instantly generates pros/cons analysis
- `[ ]` **AI Summary** — Smart summary of any document
- `[ ]` **Generate Report** — Creates a formatted PDF/DOC with the analysis
- `[ ]` **Share** — Share generated report via chat or external apps
- `[ ]` **24-Hour Auto-Delete** — Documents and analysis auto-deleted after 24 hrs
- `[ ]` **Deletion Notification** — Push notification before auto-delete ("Your document expires in 1 hour")
- `[ ]` **Privacy First** — No document stored on server permanently

### Backend
- `[ ]` POST /api/ai/analyze — Upload doc, return AI analysis (pros/cons/summary)
- `[ ]` GET /api/ai/documents — List user's active documents (< 24h)
- `[ ]` GET /api/ai/documents/:id/report — Download generated PDF
- `[ ]` Cron job — Auto-delete docs older than 24 hrs
- `[ ]` FCM notification — Sent 1 hour before expiry

### Frontend
- `[ ]` New tab or section under "Samvad AI" bot
- `[ ]` File picker (PDF, DOC, TXT, images)
- `[ ]` Loading animation while AI processes
- `[ ]` Results card: Summary, Pros, Cons sections
- `[ ]` "Generate PDF" button → creates shareable report
- `[ ]` "Share" button → share via chat or system share
- `[ ]` Timer badge showing time until auto-delete
- `[ ]` History list of past 24h documents

---

## 🚀 Deployment Strategy — Real-World Production Checklist

### Infrastructure

| Component | URL / Location | Port | Status |
|-----------|--------------|------|--------|
| Azure VM | 4.240.113.245 | — | ✅ Running |
| Nginx Reverse Proxy | web.uponlytech.com | 443 (SSL) | ✅ |
| Sambad Backend (Node.js) | PM2: `sambad-backend` | 4000 | ✅ Online |
| Admin Backend (Node.js) | PM2: `sambad-admin-backend` | — | ✅ Online |
| PostgreSQL DB | localhost | 5432 | ✅ Connected |
| WebSocket | `wss://web.uponlytech.com/sambad-backend/ws` | — | ✅ Verified |
| Admin Frontend | `web.uponlytech.com/sambad-admin/` | — | ✅ Deployed |

### Nginx Config (key blocks in `/etc/nginx/sites-enabled/web-uponlytech`)

```
# WebSocket — Must be BEFORE /sambad-backend/
location ^~ /sambad-backend/ws {
    proxy_pass http://127.0.0.1:4000/ws;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_read_timeout 3600s;
}

# Backend API
location /sambad-backend/ {
    rewrite ^/sambad-backend/(.*) /$1 break;
    proxy_pass http://sambad_backend;  # upstream → 127.0.0.1:4000
}
```

### CI/CD Pipeline

| Workflow | Trigger | What it Does |
|----------|---------|-------------|
| `deploy.yml` | Push to `samvad` branch | SSH → git pull → npm install → npm build → pm2 restart → nginx WS check |
| `deploy-admin-web.yml` | Push to `samvad` (admin frontend changes) | Flutter web build → SCP to VM |
| `build-apk.yml` | Manual dispatch | Builds APK/AAB for Play Store |

### Backend API Routes (All under `/sambad-backend/`)

| Route | Auth | Tested |
|-------|------|--------|
| `POST /api/users/login` | 🔓 Public | ✅ |
| `GET /api/health` | 🔓 Public | ✅ |
| `GET /api/app-config` | 🔓 Public | ✅ |
| `POST /api/feedback` | 🔓 Public | ✅ |
| `GET/POST /api/messages` | 🔒 Firebase Token | ✅ |
| `PUT /api/messages/:id/delivered` | 🔒 Firebase Token | ✅ |
| `PUT /api/messages/:id/read` | 🔒 Firebase Token | ✅ |
| `GET/POST /api/groups` | 🔒 Firebase Token | ✅ |
| `PUT /api/groups/:id` | 🔒 Firebase Token + Admin | ✅ |
| `DELETE /api/groups/:id` | 🔒 Firebase Token + Admin | ✅ |
| `POST /api/groups/:id/messages` | 🔒 Firebase Token + Member | ✅ |
| `POST /api/groups/:id/members` | 🔒 Firebase Token + Admin | ✅ |
| `POST /api/groups/:id/exit` | 🔒 Firebase Token | ✅ |
| `GET /api/users/:id/status` | 🔒 Firebase Token | ✅ |
| `GET /api/users/online` | 🔒 Firebase Token | ✅ |
| `POST /api/users/fcm-token` | 🔒 Firebase Token | ✅ |
| `PUT /api/users/:id` | 🔒 Firebase Token | ✅ |
| `GET /api/admin/*` | 🔒 Admin Auth | ✅ |
| `WebSocket /ws` | Query: `?userId=` | ✅ |

### Real-Time Features (WebSocket Events)

| Event | Direction | Purpose |
|-------|-----------|---------|
| `connected` | Server → Client | Welcome on WS connect |
| `new_message` | Server → Recipient | 1:1 message delivery |
| `message_sent` | Server → Sender | Multi-device echo |
| `message_delivered` | Server → Sender | Double-tick ✓✓ |
| `message_read` | Server → Sender | Blue tick |
| `group_message` | Server → Members | Group chat with `fromName` |
| `group_added` | Server → New Member | Added to group |
| `group_removed` | Server → Removed Member | Kicked from group |
| `group_updated` | Server → Members | Name/desc changed |
| `group_deleted` | Server → Members | Group deleted |
| `group_role_changed` | Server → Member | Promoted/demoted |
| `member_exited` | Server → Remaining | Someone left |
| `user_online` | Server → All | Green dot |
| `user_offline` | Server → All | Grey dot |
| `typing` | Server → Recipient | Typing indicator |
| `stop_typing` | Server → Recipient | Stopped typing |

### Pre-Release Checklist

- `[x]` Backend deployed and healthy
- `[x]` Database connected (PostgreSQL)
- `[x]` WebSocket connects via `wss://`
- `[x]` 1:1 messaging works end-to-end
- `[x]` Group messaging works end-to-end
- `[x]` Delivery + read receipts work
- `[x]` Online status broadcasts work
- `[x]` Feedback module works
- `[x]` App config (invite text) works
- `[x]` RBAC enforced (admin-only group ops)
- `[x]` Nginx reverse proxy + SSL configured
- `[x]` PM2 process management with auto-restart
- `[ ]` **iOS App Store** — Xcode signing (Apple ID login needed)
- `[ ]` **Android AAB** — Rebuild after all features complete
- `[ ]` **Firebase Console** — Disable test phone numbers
- `[ ]` **Upload key reset** — Pending Google approval
- `[ ]` **FCM Push Notifications** — Verify on real device
- `[ ]` **Samvad AI Tab** — Feature not yet implemented

### Monitoring & Troubleshooting

```bash
# SSH into server
ssh uponly-azure-uat@4.240.113.245  # Passcode: Uponly@Azure2025

# Check process status
pm2 list
pm2 logs sambad-backend --lines 50

# Restart backend
pm2 restart sambad-backend

# Check nginx
sudo nginx -t && sudo systemctl reload nginx
sudo cat /etc/nginx/sites-enabled/web-uponlytech

# Test endpoints
curl https://web.uponlytech.com/sambad-backend/api/health

# Run E2E test (from local machine)
FB_TOKEN="<firebase-id-token>" node app_user/backend/e2e_test.js

# ⚠️ Disk usage is at 93.7% — clean up if needed
df -h /
sudo apt clean && sudo journalctl --vacuum-time=3d
```

## Session 4: Apr 11 — v4.1.0 Release

| # | Issue | Severity | Status | Details |
|---|-------|----------|--------|---------|
| 44 | Country code picker incomplete (12 countries) | 🟡 Medium | ✅ Fixed | Expanded to 202 countries with searchable picker, flags, and accurate digit counts |
| 45 | Group Info members overflow | 🔴 Critical | ✅ Fixed | Wrapped in Flexible, show "Member" for unresolved UIDs, added padding |
| 46 | Individual chat — no profile navigation | 🟡 Medium | ✅ Fixed | New ContactProfilePage + wired GestureDetector in chat_page.dart |
| 47 | Add Contact — no phone contact search | 🟡 Medium | ✅ Fixed | Rebuilt dialog with tabs: Phone Contacts (search + one-tap add) and Manual Entry |
| 48 | Sync Phone Contacts — no local add | 🔴 Critical | ✅ Fixed | ContactsSyncService now uses addContactsBatch to add to ChatService locally |
| 49 | Sync button label unclear | 🟢 Low | ✅ Fixed | Renamed "Sync" → "Sync Contacts", elevated button with loading state |

### New Files
- `contact_profile_page.dart` — Read-only profile view for individual contacts (online status, phone, avatar)

### Modified Files
- `add_contact_dialog.dart` — Two-tab dialog (📱 Phone Contacts / ✏️ Manual Entry) with search, sync, and batch add
- `contacts_sync_service.dart` — Fixed core bug: now adds contacts to ChatService locally + pushes to backend
- `chat_page.dart` — Added navigation to ContactProfilePage for 1:1 chats
- `home_page.dart` — Passes context to syncContacts, shows accurate add count
- `login_screen.dart` — Uses searchable country code picker with 202 countries
- `country_codes.dart` — Expanded from 132 to 202 entries
- `group_info_page.dart` — Fixed member row overflow, "Member" label for unresolved UIDs

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| v4.1.0 | Apr 11, 2026 | Phone contact sync, contact profile navigation, 202 country codes, group info layout fix |
| v4.0.11 | Apr 10, 2026 | Screen protector fix, light/dark theme, admin features, group management |
| v4.0.10 | Apr 9-10, 2026 | 16 original bugs + 27 testing gaps, E2E verified |

---

## Compilation & Runtime Status

- **Version**: v4.1.0
- **Build**: ✅ Compiles clean (Android + iOS)
- **Runtime Errors**: ✅ No null check errors
- **Network**: ✅ All API endpoints reachable and authenticated
- **WebSocket**: ✅ Real-time delivery verified (35/35 E2E tests pass)
- **Screen Protector**: ✅ Disabled in debug mode
- **Theme**: ✅ Light/dark mode fully working
- **Contact Sync**: ✅ Phone contacts batch-add to Home tab
- **Profile Nav**: ✅ Individual + Group profile navigation working
- **Disk**: ⚠️ Server at 93.7% — needs cleanup before next deploy

