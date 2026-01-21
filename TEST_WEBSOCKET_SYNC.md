# 🧪 Test WebSocket Sync - Complete Guide

**Status:** ⚠️ **Backend needs to be started manually first**

---

## ⚠️ Current Issue

The backend server is **not starting automatically**. You need to start it manually in a terminal.

---

## ✅ All Code Fixes Are Applied

The following fixes are **permanent** and ready:

1. ✅ WebSocket connection logging added
2. ✅ Message API integration (POST /api/messages)
3. ✅ Event field fixes in dashboard
4. ✅ Backend error handling improved

---

## 🚀 How to Start & Test

### Step 1: Start Backend (REQUIRED)

**Open a terminal and run:**
```bash
cd /Users/shamrai/Desktop/sambad/app_user/backend
npm run dev
```

**Wait for this output:**
```
✅ Unified backend listening on port 4000
🔌 WebSocket: ws://localhost:4000/ws
```

**If you see errors:**
- Check if port 4000 is in use: `lsof -i :4000`
- Kill existing process: `lsof -ti :4000 | xargs kill -9`
- Try again: `npm run dev`

---

### Step 2: Verify Backend is Running

**In another terminal:**
```bash
curl http://localhost:4000/
```

**Should see:**
```
Sambad Unified Backend is running!
```

---

### Step 3: Run Automated Test

**Once backend is running:**
```bash
cd /Users/shamrai/Desktop/sambad
./test_sync.sh
```

**This will:**
1. Create two test users
2. Add a contact (triggers WebSocket event)
3. Verify contact is in database
4. Check WebSocket broadcast

---

### Step 4: Test with Admin Dashboard

1. **Start Dashboard** (if not running):
   ```bash
   cd /Users/shamrai/Desktop/sambad/sambad_admin/frontend
   flutter run -d chrome --web-port=8080
   ```

2. **Open Dashboard:**
   - URL: http://localhost:8080
   - Login: `7718811069` / `Taksh@060921`

3. **Open Browser Console (F12):**
   - Should see: `🔌 Connecting to WebSocket: ws://localhost:4000/ws`
   - Should see: `✅ WebSocket connection established`

4. **Test from Android App:**
   - Add a contact
   - Send a message
   - Dashboard should update **immediately** in "Recent Activity"

---

## 🧪 Manual Test Steps

### Test 1: Add Contact via API

```bash
# Step 1: Create User 1
curl -X POST http://localhost:4000/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"mobileNumber": "9999999999", "countryCode": "+91"}'

# Note the user ID from response (e.g., "id": "abc-123")

# Step 2: Create User 2
curl -X POST http://localhost:4000/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"mobileNumber": "8888888888", "countryCode": "+91"}'

# Note the user ID from response (e.g., "id": "xyz-456")

# Step 3: Add Contact (replace USER1_ID and USER2_ID)
curl -X POST http://localhost:4000/api/contacts \
  -H "Content-Type: application/json" \
  -d '{"userId": "USER1_ID", "contactUserId": "USER2_ID"}'
```

**Expected Result:**
- ✅ HTTP 201 response
- ✅ Backend console shows: `📡 Contact added event broadcast`
- ✅ Dashboard console shows: `📨 WebSocket message received: contact_added`
- ✅ Dashboard "Recent Activity" updates immediately

---

### Test 2: Send Message via API

```bash
# Send message (replace FROM_USER_ID and TO_USER_ID)
curl -X POST http://localhost:4000/api/messages \
  -H "Content-Type: application/json" \
  -d '{
    "fromUserId": "FROM_USER_ID",
    "toUserId": "TO_USER_ID",
    "content": "Test message for WebSocket sync",
    "type": "text"
  }'
```

**Expected Result:**
- ✅ HTTP 201 response
- ✅ Backend console shows: `📡 Message sent event broadcast`
- ✅ Dashboard console shows: `📨 WebSocket message received: message_sent`
- ✅ Dashboard "Recent Activity" updates immediately

---

## 🔍 Verification Checklist

### Backend Status:
- [ ] Backend is running (`curl http://localhost:4000/`)
- [ ] WebSocket server initialized (check backend console)
- [ ] Port 4000 is listening (`lsof -i :4000`)

### Dashboard Status:
- [ ] Dashboard is running (`lsof -i :8080`)
- [ ] WebSocket connected (check browser console)
- [ ] No connection errors in browser console

### WebSocket Sync:
- [ ] Events are broadcast (check backend console)
- [ ] Events are received (check dashboard browser console)
- [ ] UI updates in real-time (check "Recent Activity")

---

## 🐛 Troubleshooting

### Backend Won't Start

**Check:**
```bash
# Is port 4000 in use?
lsof -i :4000

# Are there TypeScript errors?
cd app_user/backend
npx tsc --noEmit

# Check if database file exists
ls -la app_user/backend/sambad_user.db
```

**Fix:**
- Kill process: `lsof -ti :4000 | xargs kill -9`
- Reinstall: `cd app_user/backend && npm install`
- Check logs for errors

### WebSocket Not Connecting

**Check:**
- Is backend running? `curl http://localhost:4000/`
- Browser console for errors (F12)
- WebSocket URL: Should be `ws://localhost:4000/ws`

**Fix:**
- Restart backend
- Clear browser cache
- Check CORS settings (should be enabled)

### Events Not Showing

**Check:**
- Dashboard is open and connected
- Backend is broadcasting (check backend console)
- Browser console shows received events

**Fix:**
- Events only sync when dashboard is **connected**
- Try adding a **new** contact/message while dashboard is open
- Check browser console for JavaScript errors

---

## 📊 Expected Flow (Working)

```
1. Backend starts → WebSocket server on /ws
2. Dashboard connects → WebSocket client connects
3. Android app action → POST /api/contacts or /api/messages
4. Backend emits → emitContactAdded() or emitMessageSent()
5. WebSocket broadcasts → All connected clients
6. Dashboard receives → onEvent() callback
7. UI updates → setState() → Activity shows in real-time ✨
```

---

## ✅ Summary

**All code fixes are permanent and ready.** 

**To test:**
1. Start backend manually: `cd app_user/backend && npm run dev`
2. Start dashboard: `cd sambad_admin/frontend && flutter run -d chrome --web-port=8080`
3. Test with Android app or API
4. Verify sync in dashboard "Recent Activity"

**Once backend is running, all sync functionality should work!** 🎉
