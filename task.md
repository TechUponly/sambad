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
| 23 | Group tile — no menu options | 🔴 Critical | `[ ]` Open | Need: exit, delete, block/mute, info |
| 24 | No Group Info/Profile page | 🔴 Critical | `[ ]` Open | Name, description, member list, admin controls |
| 25 | No edit group name/description | 🟡 Medium | `[ ]` Open | Admin should be able to edit group details |
| 26 | No add/remove members UI | 🟡 Medium | `[ ]` Open | Admin should manage members from group info |
| 27 | No group admin role | 🟡 Medium | `[ ]` Open | Creator = admin, can promote others |
| 28 | No exit group option | 🔴 Critical | `[ ]` Open | User should be able to leave a group |
| 29 | No mute/block group | 🟡 Medium | `[ ]` Open | Mute notifications, block group |
| 30 | Group messages — no sender name | 🟡 Medium | `[ ]` Open | Chat bubbles should show who sent in group |
| 31 | Group model missing description | 🟡 Medium | `[ ]` Open | Backend Group entity needs description column |

---

## Group Feature Checklist (#23-31)

### Backend
- `[ ]` Add `description` and `icon` columns to Group model
- `[ ]` Add `role` column to GroupMember model (admin/member)
- `[ ]` PUT /api/groups/:id — edit group name/description
- `[ ]` DELETE /api/groups/:id — delete group (admin only)
- `[ ]` Make creator auto-admin in POST /api/groups

### Frontend — Group Info Page (NEW)
- `[ ]` Group info/profile page with name, description, member list
- `[ ]` Edit group name (admin only)
- `[ ]` Edit group description (admin only)
- `[ ]` Add member button (admin only)
- `[ ]` Remove member (admin only)
- `[ ]` Promote/demote admin (admin only)
- `[ ]` Exit group button
- `[ ]` Delete group button (admin only)

### Frontend — Group Tile Menu
- `[ ]` PopupMenuButton on group tiles (like contacts)
- `[ ]` "Group Info" option → opens group info page
- `[ ]` "Mute" option → mute notifications
- `[ ]` "Exit Group" option
- `[ ]` "Delete Group" option (admin only)

### Frontend — Group Chat
- `[ ]` Show sender name on group message bubbles
- `[ ]` Show member count in chat app bar

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

## Pending Non-Code Items

- ⏳ **Upload key reset** — Pending Google approval (~24-48h)
- 📦 **AAB** — Needs rebuild after group features complete
- 🔥 **Firebase Console** — Disable test phone numbers before release
- 🌐 **WebSocket** — Deploy will fix nginx, needs verification
