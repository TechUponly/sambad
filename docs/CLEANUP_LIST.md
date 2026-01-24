# Files Safe to Delete

## Backend
```
app_user/backend/src/index.ts.incomplete
app_user/backend/src/index.ts.no-posts
app_user/backend/src/index.ts.before-flutter-fix
app_user/backend/sambad_user.db (old SQLite)
```

## Admin
```
sambad_admin/backend/admin.db (empty SQLite)
```

## Old PostgreSQL Databases
```
DROP DATABASE sambad;           # old
DROP DATABASE sambad_admin;     # old
KEEP: sambad_unified           # ✅ ACTIVE
```

## Note
⚠️ DO NOT delete any files in:
- src/models/
- src/routes/
- lib/services/

These contain business logic!
