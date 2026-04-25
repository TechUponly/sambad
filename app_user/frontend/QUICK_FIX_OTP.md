# Quick Fix: OTP Not Working

## 3-Minute Fix

### Step 1: Enable Phone Auth (1 minute)
1. Open: https://console.firebase.google.com/project/private-sambad/authentication/providers
2. Click "Phone"
3. Toggle "Enable"
4. Click "Save"

### Step 2: Add Test Number (1 minute)
1. Scroll down to "Phone numbers for testing"
2. Click "Add phone number"
3. Enter:
   - Phone: `+1 650-555-1234`
   - Code: `123456`
4. Click "Add"
5. Click "Save"

### Step 3: Test (1 minute)
```bash
cd frontend
flutter run
```

In the app:
1. Enter: `+1 650-555-1234`
2. Click "Send OTP"
3. Enter: `123456`
4. ✅ Should log in!

---

## Alternative Test Numbers

Add these for more testing options:

```
+1 555-555-5555 → 111111
+91 9876543210 → 123456
+44 7700 900000 → 999999
```

---

## Still Not Working?

Run diagnostic:
```bash
cd frontend
./test_otp_setup.sh
```

Check Xcode console:
```bash
open ios/Runner.xcworkspace
```
Then run and check console for errors.

---

## Common Issues

**Nothing happens when clicking "Send OTP"**
→ Phone Auth not enabled in Firebase Console

**Error: "reCAPTCHA verification failed"**
→ Need real REVERSED_CLIENT_ID (see FIX_OTP_ISSUE.md)

**Error: "Invalid phone number"**
→ Must include country code (e.g., +1, +91)

---

## For Production

Later, you'll need to:
1. Download real GoogleService-Info.plist
2. Update REVERSED_CLIENT_ID
3. Configure APNs for real SMS

But for now, test numbers work perfectly for development!

---

**Firebase Console:**  
https://console.firebase.google.com/project/private-sambad/authentication/providers
