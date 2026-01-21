# Admin Credentials Setup

## Your Credentials

Based on the Flutter app code, you have these credentials:

- **Username:** `7718811069`
- **Password:** `Taksh@060921`

## Current Issue

The backend isn't starting due to a **TypeScript module resolution error**, NOT because of credentials. However, we need to:

1. ✅ Fix the backend startup issue (TypeScript/ts-node configuration)
2. ✅ Create admin user with your credentials in the database
3. ✅ Ensure Flutter app uses these credentials

## Steps to Fix

### 1. Create Admin User (once backend is running)

```bash
cd app_user/backend
npx ts-node scripts/create-admin.ts 7718811069 "Taksh@060921" admin@sambad.com superadmin
```

### 2. Flutter Login

The Flutter app already has fallback support for these credentials via SHA-256 hash checking. Once the backend is running, it will:

1. First try REST API login with whatever you type
2. If that fails, fallback to SHA-256 hash check for `7718811069`/`Taksh@060921`
3. If hash matches, it will also try to authenticate with API

### 3. Use Your Credentials

When logging in through Flutter:
- **Username:** `7718811069`
- **Password:** `Taksh@060921`

Or create a new admin:
- **Username:** `admin` (or any username)
- **Password:** `admin123` (or any password)

## Summary

**The credentials are NOT the issue** - the backend TypeScript compilation error is preventing startup. Once the backend starts, the credentials will work fine.
