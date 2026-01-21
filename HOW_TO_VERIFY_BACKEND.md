# ✅ How to Verify Backend is Running

**Date:** 2025-01-17

---

## 🔍 **How to Check if Backend is Running**

### **1. Check Port 4000:**
```bash
lsof -i :4000
```

**Expected output:**
```
COMMAND   PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
node    12345   user   18u  IPv4  ...      0t0  TCP *:4000 (LISTEN)
```

### **2. Test HTTP Endpoint:**
```bash
curl http://localhost:4000/
```

**Expected output:**
```
Sambad Unified Backend is running!
✅ Backend API: http://localhost:4000/api
...
```

### **3. Check Process:**
```bash
ps aux | grep "npm run dev" | grep -v grep
```

**Expected:** Should show nodemon/ts-node process

---

## ⚠️ **If Backend is NOT Running**

### **Signs:**
- ❌ `lsof -i :4000` shows nothing
- ❌ `curl http://localhost:4000/` fails
- ❌ No process listening on port 4000

### **Solution:**
```bash
cd /Users/shamrai/Desktop/sambad/app_user/backend
npm run dev
```

**Look for in terminal:**
```
✅ Unified backend listening on port 4000
🔌 WebSocket: ws://localhost:4000/ws
```

**If you see errors:**
- Share the error message
- Check if port 4000 is already in use: `lsof -i :4000`
- Kill existing process: `lsof -ti :4000 | xargs kill -9`

---

## 🧪 **Once Backend is Running - Test Sync**

### **Run Automated Test:**
```bash
cd /Users/shamrai/Desktop/sambad
./test_sync.sh
```

**Expected output:**
```
✅ Backend is responding
✅ Test users created
✅ Contact added (ID: ...)
✅ Contact is in database
📡 This should have triggered a WebSocket event
```

---

## 📊 **Current Status Check**

Run this to check everything:
```bash
cd /Users/shamrai/Desktop/sambad
./check_sync_status.sh
```

---

## ✅ **All Code Fixes are Ready**

Once backend is running:
- ✅ WebSocket sync will work
- ✅ Contact addition will trigger events
- ✅ Message sending will trigger events
- ✅ Dashboard will receive real-time updates

---

**Please check if backend shows "✅ Unified backend listening on port 4000" in your terminal!** 🚀
