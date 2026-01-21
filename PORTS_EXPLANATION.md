# 🔌 Ports Explanation - Sambad Architecture

**Date:** 2025-01-17

---

## 📊 Two Ports Architecture

### **Port 4000 - Backend Server** 
**Purpose:** API Server + WebSocket Server

**What runs on port 4000:**
- ✅ **Backend API** (Express/Node.js)
  - REST endpoints: `/api/users`, `/api/contacts`, `/api/messages`
  - Admin endpoints: `/api/admin/*`
  
- ✅ **WebSocket Server** (`ws://localhost:4000/ws`)
  - Real-time event broadcasting
  - `contact_added`, `message_sent`, `user_created` events
  
- ✅ **Database** (SQLite)
  - Stores all data: users, contacts, messages
  
**Location:** `app_user/backend/src/index.ts`  
**Start:** `cd app_user/backend && npm run dev`

---

### **Port 8080 - Admin Dashboard (Flutter Web)**
**Purpose:** Admin Dashboard UI

**What runs on port 8080:**
- ✅ **Flutter Web App** (Admin Dashboard)
  - Login page
  - Dashboard with analytics
  - Users management
  - Real-time activity feed
  
- ✅ **WebSocket Client** (Connects to port 4000)
  - Connects to: `ws://localhost:4000/ws`
  - Receives real-time events from backend
  
**Location:** `sambad_admin/frontend/`  
**Start:** `cd sambad_admin/frontend && flutter run -d chrome --web-port=8080`

---

## 🔄 How They Work Together

```
┌─────────────────────┐         ┌─────────────────────┐
│                     │         │                     │
│  Android App        │────────▶│  Backend (Port 4000)│
│                     │  POST   │                     │
│  (User app)         │  /api   │  - API Endpoints    │
└─────────────────────┘         │  - WebSocket Server │
                                │  - Database         │
                                └──────────┬──────────┘
                                           │
                                           │ WebSocket Events
                                           │ (ws://localhost:4000/ws)
                                           ▼
                                ┌─────────────────────┐
                                │                     │
                                │  Admin Dashboard    │
                                │  (Port 8080)        │
                                │                     │
                                │  - Flutter Web UI   │
                                │  - WebSocket Client │
                                │  - Real-time Updates│
                                └─────────────────────┘
```

---

## 📱 Flow Example: Adding Contact

1. **Android App** → `POST /api/contacts` → **Backend (Port 4000)**
2. **Backend** → Saves to database → Emits `contact_added` event
3. **WebSocket Server** → Broadcasts event to all connected clients
4. **Admin Dashboard (Port 8080)** → Receives event via WebSocket
5. **Dashboard UI** → Updates "Recent Activity" in real-time ✨

---

## 🚀 Why Two Ports?

### **Separation of Concerns:**
- **Port 4000 (Backend):** API + WebSocket + Database (server-side)
- **Port 8080 (Dashboard):** UI only (client-side)

### **Independent Deployment:**
- Backend can run on different server/port
- Dashboard can be deployed separately
- Can run multiple dashboard instances (same backend)

### **Development:**
- Run backend: `cd app_user/backend && npm run dev`
- Run dashboard: `cd sambad_admin/frontend && flutter run -d chrome --web-port=8080`
- Each in separate terminal, independent restarts

---

## 🔧 Port Configuration

### **Backend Port 4000:**
**File:** `app_user/backend/src/index.ts`
```typescript
const PORT = Number(process.env.PORT || 4000);
server.listen(PORT, () => {
  console.log(`✅ Unified backend listening on port ${PORT}`);
});
```

### **Dashboard Port 8080:**
**Command:** `flutter run -d chrome --web-port=8080`

**WebSocket Connection:**
**File:** `sambad_admin/frontend/lib/screens/dashboard_screen.dart`
```dart
AdminWebSocket().connect(
  url: 'ws://localhost:4000/ws',  // Connects to backend port
  onEvent: (event) { ... }
);
```

---

## 📊 Summary

| Port | Service | Purpose | Start Command |
|------|---------|---------|---------------|
| **4000** | Backend API | API + WebSocket + Database | `cd app_user/backend && npm run dev` |
| **8080** | Admin Dashboard | Flutter Web UI | `cd sambad_admin/frontend && flutter run -d chrome --web-port=8080` |

---

## 💡 Why Not One Port?

**Could we use one port?** Yes, but:
- ❌ Dashboard would need to be served by backend (less flexible)
- ❌ Can't develop dashboard independently
- ❌ Harder to deploy separately
- ❌ Flutter web needs its own dev server

**Two ports is better for:**
- ✅ Independent development
- ✅ Separate deployment
- ✅ Multiple dashboard instances
- ✅ Better architecture (client-server separation)

---

**The two-port architecture is intentional and provides better separation and flexibility!** ✨
