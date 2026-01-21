# Manual Run - Visual Guide

## 🚀 Step-by-Step: Run Server & View in Chrome

### Step 1: Open Terminal

Open a terminal window and navigate to:
```bash
cd /Users/shamrai/Desktop/sambad/sambad_admin/backend
```

### Step 2: Set Environment Variables

```bash
export ADMIN_DB_USER=postgres
export ADMIN_DB_PASSWORD=changeme
export ADMIN_DB_NAME=sambad_admin
export ADMIN_JWT_SECRET=test-secret-123
export USER_BACKEND_URL=http://localhost:4000/api
export ADMIN_PORT=5050
```

### Step 3: Start the Server

```bash
npm run dev
```

**Expected Output:**
```
Admin backend listening on port 5050
Health check: http://localhost:5050/
Login: POST http://localhost:5050/login
```

### Step 4: Open Chrome

Open Chrome browser and navigate to:
```
http://localhost:5050/
```

### Step 5: What You'll See

#### **Login Screen:**
```
┌─────────────────────────────────────┐
│  🚀 Sambad Admin Dashboard          │
│  Backend API Testing & Visualization│
├─────────────────────────────────────┤
│                                     │
│  Login                              │
│                                     │
│  Username: [testadmin          ]   │
│  Password: [TestAdmin123!       ]   │
│                                     │
│  [        Login        ]            │
│                                     │
└─────────────────────────────────────┘
```

#### **After Login - Dashboard:**
```
┌─────────────────────────────────────────────────────┐
│  Dashboard                                          │
│  Logged in as: testadmin (superadmin)  [Logout]    │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │ Total    │  │ New      │  │ Total    │         │
│  │ Users    │  │ Users    │  │ Messages │         │
│  │   150    │  │    5     │  │   2340   │         │
│  └──────────┘  └──────────┘  └──────────┘         │
│                                                     │
│  Recent Activity                                   │
│  ┌─────────────────────────────────────────────┐  │
│  │ Description          │ Time                 │  │
│  ├─────────────────────────────────────────────┤  │
│  │ Message from user1... │ 2025-01-14 16:00:00 │  │
│  │ Contact added: user2  │ 2025-01-14 15:45:00 │  │
│  └─────────────────────────────────────────────┘  │
│                                                     │
│  Users                                              │
│  ┌─────────────────────────────────────────────┐  │
│  │ ID    │ Username │ Email        │ Status   │  │
│  ├─────────────────────────────────────────────┤  │
│  │ uuid1 │ user1    │ user1@...    │ active   │  │
│  │ uuid2 │ user2    │ user2@...    │ active   │  │
│  └─────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

## 🧪 Testing the API

### Test 1: Health Check
```bash
curl http://localhost:5050/
```
**Expected:** `Sambad Admin Backend is running!`

### Test 2: Login
```bash
curl -X POST http://localhost:5050/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testadmin","password":"TestAdmin123!"}'
```
**Expected:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "admin": {
    "id": "6ab46356-7920-4311-8a05-e011ed3fabd6",
    "username": "testadmin",
    "email": "testadmin@sambad.com",
    "role": "superadmin"
  }
}
```

### Test 3: Protected Endpoint (With Token)
```bash
TOKEN="your-token-here"
curl http://localhost:5050/analytics \
  -H "Authorization: Bearer $TOKEN"
```
**Expected:** Analytics JSON data

### Test 4: Protected Endpoint (Without Token)
```bash
curl http://localhost:5050/analytics
```
**Expected:** `401 Unauthorized`

## 🎨 Dashboard Features

✅ **Modern UI Design**
- Gradient background
- Card-based layout
- Responsive design

✅ **Real-time Data**
- Fetches data from backend API
- Updates on login
- Shows live statistics

✅ **Security**
- JWT token authentication
- Token stored in localStorage
- Auto-logout functionality

✅ **Error Handling**
- Shows error messages
- Handles API failures gracefully
- User-friendly feedback

## 🔧 Troubleshooting

### Server Won't Start

1. **Check PostgreSQL:**
   ```bash
   psql -U postgres -d sambad_admin -c "SELECT 1;"
   ```

2. **Check Port:**
   ```bash
   lsof -i :5050
   ```
   If port is in use, kill the process or change `ADMIN_PORT`

3. **Check Dependencies:**
   ```bash
   npm install
   ```

### Dashboard Shows Errors

1. **Check Browser Console:**
   - Open Chrome DevTools (F12)
   - Check Console tab for errors
   - Check Network tab for failed requests

2. **Check CORS:**
   - Make sure server is running
   - Check if API calls are being blocked

3. **Check Token:**
   - Try logging out and logging back in
   - Check localStorage in DevTools

## 📊 What Gets Displayed

- **Total Users:** Count from `/analytics` endpoint
- **New Users Today:** Users created today
- **Total Messages:** Count from `/analytics` endpoint
- **Recent Activity:** Last 10 items from `/activity` endpoint
- **Users List:** First 20 users from `/users` endpoint

---

**Once server starts, everything will work automatically in the Chrome dashboard!**
