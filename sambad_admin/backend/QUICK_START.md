# Quick Start - Run Server & View Dashboard

## 🚀 Simple 3-Step Process

### Step 1: Open Terminal

Open Terminal app on your Mac.

### Step 2: Run This Command

```bash
cd /Users/shamrai/Desktop/sambad/sambad_admin/backend && ./START_SERVER.sh
```

**OR manually:**

```bash
cd /Users/shamrai/Desktop/sambad/sambad_admin/backend

export ADMIN_DB_USER=postgres
export ADMIN_DB_PASSWORD=changeme
export ADMIN_DB_NAME=sambad_admin
export ADMIN_JWT_SECRET=test-secret-123
export USER_BACKEND_URL=http://localhost:4000/api
export ADMIN_PORT=5050

npx ts-node src/index.ts
```

### Step 3: Open Chrome

Once you see:
```
✅ Admin backend listening on port 5050
🌐 Dashboard: http://localhost:5050/
```

**Open Chrome and go to:**
```
http://localhost:5050/
```

## 🎯 What You'll See

1. **Login Page** - Enter credentials:
   - Username: `testadmin`
   - Password: `TestAdmin123!`

2. **Dashboard** - After login:
   - Analytics cards
   - Activity feed
   - Users table

## ⚠️ If Server Doesn't Start

Check these:

1. **PostgreSQL running?**
   ```bash
   psql -U postgres -d sambad_admin -c "SELECT 1;"
   ```

2. **Port 5050 free?**
   ```bash
   lsof -i :5050
   ```

3. **Dependencies installed?**
   ```bash
   cd /Users/shamrai/Desktop/sambad/sambad_admin/backend
   npm install
   ```

---

**The server needs to run in a terminal window so you can see the output and any errors.**
