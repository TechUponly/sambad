# Admin Backend - Code Review & Testing Guide

## ✅ Code Review Summary

### **1. Authentication Implementation (`src/middleware/auth.ts`)**

**✅ Strengths:**
- JWT-based authentication with 8-hour token expiry
- Password hashing with bcrypt (10 rounds)
- Proper error handling with generic messages (no info leakage)
- Input validation for login endpoint
- Audit logging on successful login
- Role-based authorization middleware

**✅ Security:**
- Passwords never stored in plaintext
- JWT tokens signed with secret
- Generic error messages prevent user enumeration
- Token verification on every protected route

**⚠️ Minor Issues Found:**
- `AdminLog` model needs `admin_user_id` column (fixed in code, needs migration)
- No token refresh mechanism (tokens expire after 8h)
- No logout/revocation mechanism

### **2. Main Server (`src/index.ts`)**

**✅ Strengths:**
- Environment variable configuration
- Public `/login` endpoint
- All other routes protected with `authMiddleware`
- Role-based access control per endpoint:
  - `/analytics`, `/activity`, `/messages`, `/contacts`: `superadmin`, `admin`, `moderator`
  - `/users`: also allows `viewer` role
- Proper error handling

**✅ Structure:**
- Clean separation of concerns
- Middleware applied correctly
- Environment variables for all config

### **3. Database Models**

**✅ `AdminUser` Model:**
- UUID primary key
- Unique constraints on username and email
- Password hash stored securely
- Role field with default 'moderator'
- Timestamps (created_at, updated_at)

**✅ `AdminLog` Model:**
- Foreign key to AdminUser
- Action, target_type, target_id for audit trail
- JSONB details field for flexible metadata
- Timestamp for compliance

**⚠️ Note:** Migration needed to add `admin_user_id` column to `admin_logs` table.

---

## 🧪 Manual Testing Steps

### **Prerequisites:**
1. PostgreSQL running with `sambad_admin` database
2. Admin user created (already done: `testadmin` / `TestAdmin123!`)
3. Environment variables set (see below)

### **Step 1: Set Environment Variables**

Create `.env` file in `sambad_admin/backend/` or export:

```bash
export ADMIN_DB_HOST=localhost
export ADMIN_DB_PORT=5432
export ADMIN_DB_USER=postgres
export ADMIN_DB_PASSWORD=changeme
export ADMIN_DB_NAME=sambad_admin
export ADMIN_JWT_SECRET=dev-admin-secret-change-in-production
export USER_BACKEND_URL=http://localhost:4000/api
export ADMIN_PORT=5050
```

### **Step 2: Start the Server**

```bash
cd /Users/shamrai/Desktop/sambad/sambad_admin/backend
npm install  # if not done
npm run dev
```

Expected output: `Admin backend listening on port 5050`

### **Step 3: Test Login Endpoint**

```bash
curl -X POST http://localhost:5050/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testadmin","password":"TestAdmin123!"}'
```

**Expected Response:**
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

**Test Invalid Credentials:**
```bash
curl -X POST http://localhost:5050/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testadmin","password":"wrong"}'
```

Expected: `401` with `{"error":"INVALID_CREDENTIALS",...}`

### **Step 4: Test Protected Endpoints**

**Get Token First:**
```bash
TOKEN=$(curl -s -X POST http://localhost:5050/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testadmin","password":"TestAdmin123!"}' | jq -r '.token')
```

**Test Analytics (requires auth):**
```bash
curl http://localhost:5050/analytics \
  -H "Authorization: Bearer $TOKEN"
```

**Test Without Token (should fail):**
```bash
curl http://localhost:5050/analytics
```

Expected: `401` with `{"error":"UNAUTHORIZED",...}`

**Test With Invalid Token:**
```bash
curl http://localhost:5050/analytics \
  -H "Authorization: Bearer invalid-token-here"
```

Expected: `401` with `{"error":"UNAUTHORIZED",...}`

### **Step 5: Verify Audit Logging**

After successful login, check the database:

```bash
psql -U postgres -d sambad_admin -c "SELECT action, target_type, timestamp FROM admin_logs ORDER BY timestamp DESC LIMIT 5;"
```

Should show `LOGIN` entries with timestamps.

---

## 🔧 Fixes Needed

### **1. Database Migration for admin_logs**

Run this SQL to add the missing column:

```sql
ALTER TABLE admin_logs ADD COLUMN IF NOT EXISTS admin_user_id UUID;
CREATE INDEX IF NOT EXISTS idx_admin_logs_admin_user_id ON admin_logs(admin_user_id);
```

### **2. Update Auth Middleware (Optional)**

If you want to set `admin_user_id` explicitly:

```typescript
const log = logRepo.create({
  admin_user: admin,
  admin_user_id: admin.id,  // Add this
  action: 'LOGIN',
  // ...
});
```

---

## ✅ Summary

**What Works:**
- ✅ Database tables created
- ✅ Test admin user created (`testadmin` / `TestAdmin123!`)
- ✅ Authentication code implemented
- ✅ Authorization middleware implemented
- ✅ Audit logging implemented
- ✅ Environment variable configuration

**What to Test:**
- Login endpoint with valid/invalid credentials
- Protected endpoints with/without token
- Role-based access control
- Audit log entries

**Next Steps:**
1. Run the database migration for `admin_user_id`
2. Start the server and test manually
3. Verify all endpoints work as expected

---

**Status:** Code is ready for testing. All critical security features are implemented.
