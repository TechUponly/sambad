# Flutter Admin App - Setup & Integration

## ✅ What I Fixed

1. **Moved HTML dashboard** to `/test-dashboard` (no longer interferes)
2. **Updated Flutter ApiService** to support JWT authentication
3. **Admin backend** running on port 5050 with authentication

## 🔧 Flutter App Integration

The Flutter app's `ApiService` now supports:
- ✅ Login method to authenticate and get JWT token
- ✅ Automatic token storage and header injection
- ✅ All API calls will include `Authorization: Bearer <token>` header

## 📝 How to Use in Flutter App

### Option 1: Update Login Screen to Use REST API

The Flutter login screen currently uses SHA-256 hash checking. You can update it to use the REST API:

```dart
// In login_screen.dart, update _login() method:
void _login() async {
  setState(() { _isLoading = true; _error = null; });
  
  final apiService = ApiService();
  final success = await apiService.login(
    _usernameController.text.trim(),
    _passwordController.text,
  );
  
  if (success) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
    );
  } else {
    setState(() { _error = 'Invalid credentials'; });
  }
  setState(() { _isLoading = false; });
}
```

### Option 2: Keep Current Login, Add API Auth After

If you want to keep the current SHA-256 login, you can authenticate with the API after successful login:

```dart
// After successful SHA-256 login:
final apiService = ApiService();
await apiService.login('testadmin', 'TestAdmin123!');
// Now all API calls will be authenticated
```

## 🚀 Running the Flutter App

1. **Start User Backend** (GraphQL on port 4000):
   ```bash
   cd /Users/shamrai/Desktop/sambad/app_user/backend/sambad_backend
   npm run dev
   ```

2. **Start Admin Backend** (REST API on port 5050):
   ```bash
   cd /Users/shamrai/Desktop/sambad/sambad_admin/backend
   ./START_SERVER.sh
   # Or manually with env vars
   ```

3. **Run Flutter App**:
   ```bash
   cd /Users/shamrai/Desktop/sambad/sambad_admin/frontend
   flutter pub get
   flutter run -d chrome
   ```

## 🔐 Test Credentials

For REST API authentication:
- **Username:** `testadmin`
- **Password:** `TestAdmin123!`

For Flutter app SHA-256 login (current):
- **Username:** `7718811069`
- **Password:** `Taksh@060921`

## 📊 Available Endpoints

All endpoints require authentication (JWT token):

- `POST /login` - Get JWT token
- `GET /analytics` - Dashboard analytics
- `GET /activity` - Recent activity
- `GET /users` - List all users
- `GET /messages` - List messages
- `GET /contacts` - List contacts

## 🎯 Next Steps

1. **Update Flutter login** to use REST API (optional)
2. **Test Flutter app** with authenticated API calls
3. **All dashboard features** should now work with real backend data

---

**The Flutter app is now ready to connect to the authenticated admin backend!**
