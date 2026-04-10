# Private Samvad — Bug Tracker & Task List (Apr 9, 2026)

## Sprint 4: 16/16 Original Issues ✅ + New Gaps Found During Testing

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

## Session 2: Testing Gaps Found (In Progress)

| # | Issue | Severity | Status | Details |
|---|-------|----------|--------|---------|
| 17 | Button text invisible (dark mode) | 🔴 Critical | ✅ Fixed | Added elevatedButtonTheme with foregroundColor: Colors.white |
| 18 | Blocked contact disappears | 🔴 Critical | ✅ Fixed | Now shows "Blocked" label with greyed-out UI + disabled tap |
| 19 | Can't re-add blocked contact | 🟡 Medium | ✅ Fixed | Auto-unblocks when adding same phone again |
| 20 | Profile save stays on page | 🟡 Medium | ✅ Fixed | Navigator.pop() after 500ms delay |
| 21 | WebSocket 404 in production | 🔴 Critical | `[/]` Deploy pending | Added nginx WS upgrade headers to deploy.yml |
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
| 33 | Group Info — no photo or tap-to-rename | 🟡 Medium | `[ ]` Open | Need: tap group icon to upload photo, tap name to rename inline |
| 34 | No "Add Members" after group created | 🔴 Critical | ✅ Fixed | Auto-resolves server ID from ChatService, falls back to local data |
| 35 | Feedback not sent | 🟡 Medium | `[/]` Blocked by deploy | Code correct — POST /api/feedback exists, nginx 404 same as #21 |
| 36 | Light mode not working | 🟡 Medium | ✅ Fixed | Replaced hardcoded dark colors with AppColors.of(context) theme-aware |
| 37 | Online/offline status not working | 🟡 Medium | `[ ]` Blocked by #21 | Toggle saves pref but no green dot — needs WebSocket to broadcast status |
| 38 | Samvad AI tab fully empty | 🔴 Critical | `[ ]` Open | AI bot tab shows nothing — no chat UI, no input, no functionality |

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

## Pending Non-Code Items

- ⏳ **Upload key reset** — Pending Google approval (~24-48h)
- 📦 **AAB** — Needs rebuild after group features complete
- 🔥 **Firebase Console** — Disable test phone numbers before release
- 🌐 **WebSocket** — Deploy will fix nginx, needs verification

