# Sambad API Documentation

Base URL: `https://api.sambad.com`

## Endpoints

### 1. Get All Users
- **GET** `/users`
- Returns a list of all users.
- Response:
```json
[
  {
    "id": "string",
    "name": "string",
    "location": "string",
    "persona": "string",
    "email": "string",
    "joined": "date",
    "active": true
  },
  ...
]
```

### 2. Get User Details
- **GET** `/users/{userId}`
- Returns details for a specific user.
- Response:
```json
{
  "id": "string",
  "name": "string",
  "location": "string",
  "persona": "string",
  "email": "string",
  "joined": "date",
  "active": true
}
```

### 3. Get Persona Analytics
- **GET** `/users/{userId}/analytics`
- Returns persona analytics for a user.
- Response:
```json
{
  "activityScore": 87,
  "connections": 24,
  "chats": 132,
  "lastLocation": "string",
  "personaType": "string",
  "personaDescription": "string"
}
```

### 4. Get User Chats
- **GET** `/users/{userId}/chats`
- Returns chat history for a user.
- Response:
```json
[
  {
    "chatId": "string",
    "timestamp": "date-time",
    "message": "string",
    "from": "string",
    "to": "string"
  },
  ...
]
```

### 5. Get User Live Location
- **GET** `/users/{userId}/location`
- Returns the latest location for a user.
- Response:
```json
{
  "latitude": 19.0760,
  "longitude": 72.8777,
  "timestamp": "date-time"
}
```

---

## Notes
- All endpoints return JSON.
- Authentication required for all endpoints (e.g., Bearer token).
- Extend with POST/PUT/DELETE as needed for admin actions.
