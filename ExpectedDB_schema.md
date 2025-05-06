# Expected DB Schema for Social Circle Manager

This document outlines the database schema and explains which tables should be integrated with which screens for the Social Circle Manager app.

---

## 1. Tables

### users
- **id** `UUID` (PK, default `uuid_generate_v4()`)
- **email** `TEXT` (unique, not null)
- **username** `TEXT` (unique, not null)
- **display_name** `TEXT`
- **avatar_url** `TEXT`
- **created_at** `TIMESTAMPTZ` (default now())
- **updated_at** `TIMESTAMPTZ` (default now())

### circles
- **id** `UUID` (PK, default `uuid_generate_v4()`)
- **name** `TEXT` (not null)
- **description** `TEXT`
- **icon_url** `TEXT` (optional)
- **cover_image_url** `TEXT` (optional)
- **is_public** `BOOLEAN` (default `true`)
- **created_by** `UUID` (FK → users.id)
- **created_at** `TIMESTAMPTZ` (default now())
- **updated_at** `TIMESTAMPTZ` (default now())

### circle_members
- **circle_id** `UUID` (PK part, FK → circles.id)
- **user_id** `UUID` (PK part, FK → users.id)
- **role** `TEXT` (`owner` / `admin` / `member`)
- **joined_at** `TIMESTAMPTZ` (default now())

### circle_invites
- **circle_id** `UUID` (PK part, FK → circles.id)
- **invited_user_id** `UUID` (PK part, FK → users.id)
- **invited_by** `UUID` (FK → users.id)
- **status** `TEXT` (`pending` / `accepted` / `declined`)
- **created_at** `TIMESTAMPTZ` (default now())
- **responded_at** `TIMESTAMPTZ`

### events
- **id** `UUID` (PK, default `uuid_generate_v4()`)
- **circle_id** `UUID` (FK → circles.id)
- **title** `TEXT` (not null)
- **description** `TEXT`
- **location** `TEXT`
- **start_time** `TIMESTAMPTZ` (not null)
- **end_time** `TIMESTAMPTZ`
- **is_public** `BOOLEAN` (default `false`)
- **created_by** `UUID` (FK → users.id)
- **created_at** `TIMESTAMPTZ` (default now())
- **updated_at** `TIMESTAMPTZ` (default now())

### event_attendees
- **event_id** `UUID` (PK part, FK → events.id)
- **user_id** `UUID` (PK part, FK → users.id)
- **status** `TEXT` (`invited` / `going` / `maybe` / `declined`)
- **responded_at** `TIMESTAMPTZ`

### Views
- **circle_summary**: Aggregates circles with member counts
- **upcoming_events**: Lists upcoming events per circle

### Triggers
- **set_updated_at()**: Updates `updated_at` on UPDATE for tables with that column (users, circles, events)

---

## 2. Screen ↔ Table Integration

| Screen Name                     | Integrated Tables / Views                    |
|---------------------------------|----------------------------------------------|
| **CirclesScreen**               | `circles`, **view** `circle_summary`        |
| **CircleCard**                  | Receives data from `circles` + member count |
| **CircleDetailScreen**          | `circles`, `circle_members`, `circle_invites`, `events`, `event_attendees` |
| **CreateCircleDialog**          | Writes to `circles`, then adds owner to `circle_members` |
| **CircleDetailsForm**           | Updates basic circle data before commit      |
| **(Future) EventsScreen**       | `events`, **view** `upcoming_events`, `event_attendees`, `circle_members` |
| **(Future) InvitationsScreen**  | `circle_invites`, `users`                   |
| **(Future) AttendanceScreen**   | `event_attendees`, `users`                   |

---

> **Note:** You can extend this schema with additional tables such as `notifications`, `audit_logs`, and `file_attachments` as needed. 