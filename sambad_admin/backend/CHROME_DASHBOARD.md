# Chrome Admin Dashboard - Setup Instructions

## ✅ What I Created

1. **HTML Dashboard** (`public/index.html`)
   - Beautiful, modern UI for testing admin backend
   - Login form with test credentials pre-filled
   - Dashboard showing analytics, users, and activity
   - Real-time API testing

2. **Static File Serving**
   - Updated `src/index.ts` to serve static files from `public/` folder
   - Dashboard accessible at `http://localhost:5050/`

## 🚀 How to Run

### Option 1: Manual Start (Recommended)

```bash
cd /Users/shamrai/Desktop/sambad/sambad_admin/backend

# Set environment variables
export ADMIN_DB_USER=postgres
export ADMIN_DB_PASSWORD=changeme
export ADMIN_DB_NAME=sambad_admin
export ADMIN_JWT_SECRET=test-secret-123
export USER_BACKEND_URL=http://localhost:4000/api
export ADMIN_PORT=5050

# Start server
npm run dev
# OR
npx ts-node src/index.ts
```

**Then open in Chrome:**
```
http://localhost:5050/
```

### Option 2: Use the Script

```bash
cd /Users/shamrai/Desktop/sambad/sambad_admin/backend
./start-and-open.sh
```

This will:
- Start the server
- Wait for it to be ready
- Open Chrome automatically

## 🎯 What You'll See

1. **Login Page**
   - Username: `testadmin` (pre-filled)
   - Password: `TestAdmin123!` (pre-filled)
   - Click "Login"

2. **Dashboard** (after login)
   - **Stats Cards:**
     - Total Users
     - New Users Today
     - Total Messages
   
   - **Recent Activity Table**
     - Shows recent messages and contacts
   
   - **Users Table**
     - Lists all users from the backend

## 🔧 Troubleshooting

If server doesn't start:

1. **Check database connection:**
   ```bash
   psql -U postgres -d sambad_admin -c "SELECT 1;"
   ```

2. **Check if port is in use:**
   ```bash
   lsof -i :5050
   ```

3. **Check server logs:**
   ```bash
   # If using the script
   cat /tmp/admin-server.log
   
   # If running manually, check terminal output
   ```

4. **Verify environment variables:**
   - Make sure PostgreSQL is running
   - Check database credentials match your setup

## 📝 Test Credentials

- **Username:** `testadmin`
- **Password:** `TestAdmin123!`
- **Role:** `superadmin`

## 🎨 Features

- ✅ Modern, responsive UI
- ✅ Real-time API calls
- ✅ JWT token management
- ✅ Error handling
- ✅ Auto-logout functionality
- ✅ Beautiful color scheme

---

**Once the server starts, the dashboard will be available at `http://localhost:5050/`**
