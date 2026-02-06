## Admin Config: Login Method Toggles (2025-12-31)

- The Config section in the admin console allows toggling login methods for the user app:
  - OTP Login
  - Google Login
  - Apple Login
- Each method can be enabled/disabled via a switch in the UI.
- Changes are saved and pushed to the user app in real time (backend integration required).
- Only enabled login methods are shown to users on the login page.

**Example:**

> Admin enables Google Login and disables OTP Login. User app will only show Google login option.

# Tech Stack Implemented
_Flutter (Dart), Dio (networking, migrated from http for scalability), Node.js/TypeScript backend, PostgreSQL, GraphQL API._

# Sambad Admin App Logic Documentation

## Overview
This document describes the business logic and admin control features for the Sambad admin-facing Flutter application. It is intended for administrators and developers to understand, maintain, and extend the admin app.

---

## 1. Admin Control Over User App
- Admin can enable/disable login methods for user app (OTP, Google, iOS, Face Recognition).
- Admin can toggle privacy features (screenshot/camera blocking, chat auto-deletion) for user app.
- All toggles and settings are managed via the admin panel UI and synced to the user app backend in real time.

## 2. Feature Activation
- New login methods and privacy features are only available to users when activated by admin.
- Admin can set global or user-specific rules for feature access.

## 3. Audit & Logs
- All admin actions (feature toggles, user management) are logged for audit purposes.
- Every admin action (feature toggle, user/group block/unblock, call/video access, etc.) is recorded in an audit trail.
- Each audit record includes: admin ID, action type, affected user/group, timestamp, and previous/new state.
- Audit history is accessible to super-admins for review and compliance.
- Audit logs are immutable and retained for compliance and troubleshooting.

## 4. User and Group Access Control
- Admin can block or unblock access for any individual user or group.
- Admin can select one, multiple, or all users/groups for bulk block/unblock actions.
- Blocked users/groups lose access to the app or specific features as determined by admin settings.
- All block/unblock actions are logged for audit and can be reversed by admin at any time.

## 5. Call and Video Call Access
- Admin can grant or revoke access to call and video call features for any user or group.
- Admin can enable these features globally, per user, or per group.
- In the user app, call and video call features are marked as 'coming soon' until enabled by admin.
- All changes to call/video call access are logged for audit.

## 6. Real-Time User Device Access
- Admin can request real-time access to user microphone, camera, and location after user signs in.
- User consent is required for each type of access (microphone, camera, location), even if the user is not actively using the app.
- Consent prompts must be clear and allow the user to accept or deny each permission.
- Admin can view/listen to real-time streams only for users who have granted permission.
- All access requests and user responses are logged in the audit trail.

## 7. Admin Login and Home Page
- Admin login credentials (default):
  - UserID: 7718811069
  - Passcode: Taksh@060921
- After login, admin lands on the home page with a left sidebar containing:
  - Dashboard
    - Users
    - Analytics
  - Profile
  - Settings
  - Config
  - Rights (permissions management)
  - Audit (track and review logs)
  - Logout
- Sidebar navigation is persistent and accessible from all admin pages.
- Credentials should be stored securely and changed after first use for security.

## 8. Sub-Admin Management and Rights Assignment
- Admin can create sub-admin accounts and set their login credentials.
- Each sub-admin can be assigned specific rights and actions from the Rights section (e.g., user management, feature toggles, audit access).
- Rights can be granted or revoked at any time by the main admin.
- All sub-admin creation, rights assignment, and changes are logged in the audit trail.
- Sub-admins only see and access the sections/features for which they have rights.

## 9. Admin Home Page Analytics
- The admin home page (Dashboard) displays overall analytics, including:
  - Growth rate (user base, activity)
  - Last day to present metrics
  - Year-over-year (YoY) and month-over-month (MoM) comparisons
  - Online vs. offline user counts
- Analytics can be filtered by country, state, and city.
- Data visualizations (charts, graphs) are used for clear presentation.
- Filters and analytics update in real time as data changes.

## 10. Theme Management
- The admin app includes a dark/light theme toggle located at the top right corner of the interface.
- Theme preference is saved per admin user and persists across sessions.
- The UI theme uses only the following colors: black, blue, sharp white, light yellow, light green, light purple, and light red.
- Text contrast rules:
  - Use white text on black or blue backgrounds.
  - Use black text on light yellow, light green, light purple, light red, or sharp white backgrounds.
- All UI elements and themes must follow this palette and contrast logic for accessibility and consistency.

---

*This document will be updated as new admin features and controls are added.*
