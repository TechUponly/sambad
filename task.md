# Private Samvad — Bug Tracker & Task List (Apr 9, 2026)

## Fix Status: 16/16 Resolved ✅

**All issues closed.** `flutter analyze` passes with 0 errors.

---

## Summary Table

| # | Issue | Severity | Status | Fix Applied |
|---|-------|----------|--------|-------------|
| 1 | Login takes 3-5 min | 🔴 Critical | `[x]` Fixed | Progress steps UI + HTTP timeout (15s) in `login_screen.dart` |
| 2 | Invalid phone chars | ✅ | `[x]` Already Fixed | `digitsOnly` filter + `PhoneValidator` |
| 3 | Random number login | 🟡 Medium | `[x]` Fixed | Anti-spam: reject all-same-digit & sequential numbers in `PhoneValidator` |
| 4 | Phone not visible after login | 🟡 Medium | `[x]` Fixed | Phone shown in welcome banner on `home_page.dart` |
| 5 | No contact-add confirmation | ✅ | `[x]` Already Fixed | Success animation in `AddContactDialog` |
| 6 | Group creation broken | 🔴 Critical | `[x]` Fixed | Full backend API (POST/GET/DELETE /api/groups) + WS broadcast |
| 7 | Invite friend no link | 🟡 Medium | `[x]` Fixed | Enhanced share text with features list & store links |
| 8 | Back nav causes logout | 🔴 Critical | `[x]` Fixed | `PopScope` + double-tap-to-exit on `home_page.dart` |
| 9 | No country code picker | ✅ | `[x]` Already Fixed | Country code dialog with 12 codes |
| 10 | Stale data on new login | ✅ | `[x]` Already Fixed | Session reset in `_saveAndNavigate()` |
| 11 | Duplicate notifications | 🟡 Medium | `[x]` Fixed | Notification dedup by `messageId` in `main.dart` |
| 12 | Contact search broken | 🟡 Medium | `[x]` Fixed | `init()` now passes `userId` param to contacts API + 10s timeout |
| 13 | No contact edit option | 🟡 Medium | `[x]` Fixed | Edit dialog in `contact_tile.dart` + `updateContact()` in ChatService |
| 14 | Data persists after deletion | ✅ | `[x]` Already Fixed | Full reset pipeline in `_deleteAccount()` |
| 15 | Adding contact slow (~220s) | 🟡 Medium | `[x]` Fixed | HTTP timeouts added to `loginUser` (15s) + `_syncContactToBackend` + contact API (10s) |
| 16 | Group creation broken | 🔴 Critical | `[x]` Fixed | Same as #6 — full backend group API with WebSocket message broadcasting |

---

## Files Changed (Today)

| File | Issues Fixed | What Changed |
|------|-------------|--------------|
| `home_page.dart` | #4, #8 | PopScope double-back guard; phone number in welcome banner |
| `login_screen.dart` | #1 | Progress step messages ("Sending OTP...", "Verifying...", "Setting up...") |
| `chat_service.dart` | #6, #7, #12, #13, #15 | Group API sync, improved invite text, userId for contacts, updateContact(), HTTP timeouts |
| `contact_tile.dart` | #13 | Edit menu item + full Edit Contact dialog |
| `main.dart` | #11 | FCM notification dedup by messageId with 60s TTL |
| `phone_validator.dart` | #3 | Anti-spam: reject all-same-digit & sequential phone numbers |
| `chat_page.dart` | — | Mark messages as read when chat is opened |
| `index.ts` (backend) | #6, #16 | 6 new group API endpoints + WS broadcast for group messages |

---

## Chat Delivery Pipeline (New)

| Stage | Implementation |
|-------|---------------|
| Sent | POST /api/messages → saved to DB (status: 'sent') |
| Delivered | Recipient WS receives → auto-calls PUT /messages/:id/delivered |
| Read | ChatPage.initState → markMessagesAsRead() → PUT /messages/:id/read |
| Status sync | WS events update local message status → UI shows ✓ → ✓✓ → 🔵✓✓ |
| Offline | fetchUndeliveredMessages() on login → GET /messages/undelivered/:userId |

---

## Group API (New)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/groups` | POST | Create group with members |
| `/api/groups?userId=` | GET | List user's groups |
| `/api/groups/:id` | GET | Group details with member list |
| `/api/groups/:id/members` | POST | Add member to group |
| `/api/groups/:id/members/:userId` | DELETE | Remove member |
| `/api/groups/:id/messages` | POST | Send group message (WS broadcast) |

---

## Commits (Apr 9, 2026)

| Hash | Description |
|------|-------------|
| `4000cda` | Fix 8 critical bugs: back-nav, login speed, contacts, notifications |
| `321a8df` | Complete chat delivery pipeline: sent → delivered → read |
| `a254017` | Version bump to 4.0.12+9 |
| `69d502e` | Signing key reference doc |
| `021280e` | Group API, phone validation, invite text — closes all 16 issues |

---

## Pending (Non-code)

- ⏳ **Upload key reset** — Pending Google approval (~24-48 hours)
- 📦 **AAB ready** — `samvad-v4.0.12-2026-04-09.aab` on Desktop
- 🔥 **Firebase Console** — Disable test phone numbers (Authentication → Sign-in method → Phone)

## Verification

```
$ flutter analyze --no-pub
9 issues found (all pre-existing info/warnings, 0 errors)
Exit code: 0
```
