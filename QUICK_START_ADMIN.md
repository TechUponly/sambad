# Quick Start - Admin Dashboard

## ✅ Current Status

### Backend Server
- **Port:** 4000
- **Status:** Check with `curl http://localhost:4000/`
- **Admin API:** `http://localhost:4000/api/admin/*`

### Flutter Admin App
- **Location:** `sambad_admin/frontend`
- **Starting:** Flutter app is launching in Chrome
- **Will open automatically** when ready

## 📋 Admin Login

When the Flutter app opens, use these credentials:

```
Username: admin
Password: admin123
```

(Or create your own admin with the script)

## 🔧 If Admin User Doesn't Exist

Run this command (make sure backend is running first):

```bash
cd app_user/backend
npx ts-node scripts/create-admin.ts admin admin123 admin@sambad.com superadmin
```

## 📊 What You'll See

The Flutter admin dashboard includes:

1. **Dashboard Tab**
   - Analytics cards (Total Users, New Users, Total Contacts)
   - Charts and graphs
   - Recent activity feed
   - Real-time updates

2. **Users Tab**
   - List of all registered users
   - User details (username, email, created date)
   - User management

3. **Analytics Tab**
   - Growth metrics
   - User statistics

4. **Activity Tab**
   - Real-time activity feed
   - Contact additions
   - Messages sent

5. **Other Tabs**
   - Profile
   - Settings
   - Config
   - Rights
   - Audit Log

## 🌐 Alternative: HTML Dashboard

If Flutter doesn't work, you can also access the HTML dashboard:

1. Make sure backend is running
2. Open browser: `http://localhost:4000/admin-dashboard/admin-dashboard.html`
3. Login with same credentials

## 🔍 Verify Backend is Running

```bash
# Check backend
curl http://localhost:4000/

# Should return: "Sambad Unified Backend is running!..."
```

## 🚀 All Data Visible

The admin dashboard shows:
- ✅ All users
- ✅ All contacts  
- ✅ All messages
- ✅ All groups
- ✅ Analytics and stats
- ✅ Real-time activity

Everything is pulled from the unified PostgreSQL database via the REST API!
