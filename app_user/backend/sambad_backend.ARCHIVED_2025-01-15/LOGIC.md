# Sambad Admin/Backend Logic Documentation

## Overview
This document describes the core logic and architecture of the Sambad backend (admin) system. It is intended for backend developers and administrators to understand, maintain, and extend the backend API and admin features.

---

## 1. Backend Structure
- **Location:** `sambad_backend/`
- **Tech Stack:** Node.js (TypeScript), Apollo Server (GraphQL), PostgreSQL (TypeORM), JWT, HTTPS

---

## 2. Core Features
- User registration, login, and JWT-based authentication
- Contacts management (add, search, list)
- One-to-one and group chat (messages between users)
- GraphQL API for all data access
- End-to-end encryption ready (client-side)
- Admin data model and migrations

---

## 3. API Logic
- **Authentication:**
  - JWT tokens for all API requests
  - Passwords hashed with bcrypt
- **Contacts & Users:**
  - Managed via GraphQL resolvers in `src/resolvers/`
  - Entities defined in `src/models/`
- **Messages:**
  - Stored in PostgreSQL, queried via GraphQL
  - Supports one-to-one and group chat
- **Groups:**
  - Group membership and chat managed via resolvers and models

---

## 4. Security
- HTTPS for all endpoints (add your certs)
- Input validation and sanitization
- JWT for authentication
- Passwords never stored in plain text

---

## 5. Integration with Frontend
- All data operations (auth, contacts, messages) are exposed via GraphQL API
- Flutter frontend uses a GraphQL client and JWT for all requests

---

## 6. Extensibility
- Add new features by extending resolvers and models
- Update GraphQL schema in `src/schema.graphql`
- Add migrations for new data models

---

## 7. References
- See `src/models/` for data models
- See `src/resolvers/` for API logic
- See `src/schema.graphql` for API schema
- See `README.md` for setup and usage

---

For further details, contact the backend maintainer or see the code comments in each file.
