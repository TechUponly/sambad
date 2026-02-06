# Sambad Admin Data Model (High-Level)

This document sketches tables/fields to support high-load admin use-cases: user control, analytics (with consent), and business communication via a unique user id.

> NOTE: This is a proposed schema. Before applying as migrations, compare it with your existing DB schema and adjust names/types accordingly.

---

## 1. Core Users

```sql
CREATE TABLE users (
  id              UUID PRIMARY KEY,
  phone           VARCHAR(32)  NOT NULL UNIQUE,
  email           VARCHAR(255) NULL UNIQUE,
  name            VARCHAR(255) NULL,
  status          VARCHAR(32)  NOT NULL DEFAULT 'active', -- active | blocked | deleted
  created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  last_active_at  TIMESTAMPTZ  NULL
);

CREATE INDEX idx_users_status       ON users (status);
CREATE INDEX idx_users_last_active  ON users (last_active_at DESC);
```

- `id` is the **unique user id** used everywhere (chat, analytics, admin).
- `last_active_at` is updated from the app and drives activity analytics.

---

## 2. User Consents (Analytics & Business Communication)

```sql
CREATE TABLE user_consents (
  user_id              UUID        NOT NULL PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  analytics_consent    BOOLEAN     NOT NULL DEFAULT FALSE,
  marketing_consent    BOOLEAN     NOT NULL DEFAULT FALSE,
  terms_version        VARCHAR(32) NULL,
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_user_consents_analytics  ON user_consents (analytics_consent);
CREATE INDEX idx_user_consents_marketing  ON user_consents (marketing_consent);
```

- All **analytics** queries should filter on `analytics_consent = TRUE`.
- All **business/marketing** actions (campaigns, exports) must filter on
  `marketing_consent = TRUE`.

---

## 3. Contact Channels (for later business communication)

```sql
CREATE TABLE contact_channels (
  id         UUID        PRIMARY KEY,
  user_id    UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  channel    VARCHAR(32) NOT NULL, -- email | sms | whatsapp | push | other
  address    VARCHAR(255) NOT NULL,
  verified   BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_contact_channels_user    ON contact_channels (user_id);
CREATE INDEX idx_contact_channels_channel ON contact_channels (channel);
```

- Allows you to store where and how you can legally contact a user
  (e.g. work email vs personal email, WhatsApp number, etc.).

---

## 4. Events for Analytics (High Volume)

```sql
CREATE TABLE user_events (
  id          BIGSERIAL    PRIMARY KEY,
  user_id     UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  event_type  VARCHAR(64)  NOT NULL,
  metadata    JSONB        NULL,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Common indexes for high-load analytics
CREATE INDEX idx_user_events_user_created
  ON user_events (user_id, created_at DESC);

CREATE INDEX idx_user_events_type_created
  ON user_events (event_type, created_at DESC);

-- Optional: partition by time for very high volumes
-- e.g. CREATE TABLE user_events_2025_01 PARTITION OF user_events ...
```

- Example `event_type` values: `login`, `message_sent`, `call_started`,
  `group_joined`, `profile_updated`, etc.
- Use **materialized views** or background jobs (Cron/queue) to produce
  daily aggregates (DAU, MAU, messages/day) and serve them to the admin UI.

---

## 5. Admin Users & Roles

```sql
CREATE TABLE admin_users (
  id           UUID         PRIMARY KEY,
  email        VARCHAR(255) NOT NULL UNIQUE,
  password_hash TEXT        NOT NULL,
  role         VARCHAR(32)  NOT NULL, -- super_admin | moderator | support | analyst
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  last_login_at TIMESTAMPTZ NULL
);

CREATE TABLE admin_audit_logs (
  id          BIGSERIAL    PRIMARY KEY,
  admin_id    UUID         NOT NULL REFERENCES admin_users(id) ON DELETE SET NULL,
  action      VARCHAR(128) NOT NULL,
  target_type VARCHAR(64)  NULL,
  target_id   VARCHAR(128) NULL,
  metadata    JSONB        NULL,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_admin_audit_admin_created
  ON admin_audit_logs (admin_id, created_at DESC);
```

- **Every sensitive action** in the admin console should write a row here
  (e.g. block user, unlock user, export list, view conversation, etc.).

---

## 6. Example Admin-Facing Queries

- **Dashboard overview (cached)**
  - `totalUsers`:
    ```sql
    SELECT COUNT(*) FROM users WHERE status != 'deleted';
    ```
  - `dailyActiveUsers` (only with analytics consent):
    ```sql
    SELECT COUNT(*)
    FROM users u
    JOIN user_consents c ON c.user_id = u.id
    WHERE c.analytics_consent = TRUE
      AND u.last_active_at >= NOW() - INTERVAL '1 day';
    ```

- **Admin user list (paginated)**
  ```sql
  SELECT u.id, u.name, u.phone, u.status, u.created_at, u.last_active_at,
         c.analytics_consent, c.marketing_consent
  FROM users u
  LEFT JOIN user_consents c ON c.user_id = u.id
  ORDER BY u.created_at DESC
  LIMIT :page_size OFFSET :offset;
  ```

This schema is designed to:
- Keep a **single unique user id** used in chats, analytics, and admin.
- Handle **high data volume** via indexing, event tables, and optional partitioning.
- Respect **user consent** for analytics and business communication.
- Provide a solid base for your existing and future Sambad admin API.
