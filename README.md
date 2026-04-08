# UniGuide

> "Connect, Correct, and Stay Informed."

A centralized campus Q&A and wiki platform for students, built with Flutter + Supabase.

---

## Features

- **Wiki** — Browse crowdsourced articles on exams, ERP, placements, hostel, and more. Filter by category, bookmark articles, and track view counts.
- **Q&A** — Post questions, upvote answers, and get community-verified responses. Tag questions by topic and see author year/branch context.
- **Profile** — View your posted questions, saved bookmarks, and account details.
- **Auth** — Passwordless magic link sign-in + Google OAuth. Onboarding captures year, branch, and display tag.
- **Roles** — Moderators can verify answers and manage wiki content.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Backend | Supabase (PostgreSQL + Auth + RPC) |
| State management | flutter_riverpod |
| Navigation | go_router |
| UI | Material Design 3, google_fonts (DM Sans) |
| HTML rendering | flutter_widget_from_html_core |
| Deep links | app_links |

---

## Project Structure

```
lib/
├── main.dart                          # App entry point, Supabase init
├── core/
│   ├── router.dart                    # go_router with auth redirects
│   └── theme/
│       ├── app_theme.dart             # Material 3 theme (light/dark)
│       └── theme_provider.dart        # Theme state
├── shell/
│   └── main_shell.dart                # Bottom nav shell (Wiki / Q&A / Profile)
└── features/
    ├── auth/
    │   ├── data/auth_service.dart     # Magic link + OAuth service
    │   └── presentation/screens/
    │       ├── login_screen.dart
    │       ├── check_email_screen.dart
    │       └── onboarding_screen.dart
    ├── wiki/
    │   ├── data/wiki_repository.dart  # Supabase wiki queries & models
    │   └── presentation/screens/
    │       ├── wiki_screen.dart
    │       └── wiki_article_screen.dart
    ├── qa/
    │   ├── data/qa_repository.dart    # Supabase Q&A queries & models
    │   └── presentation/screens/
    │       ├── qa_screen.dart
    │       ├── qa_detail_screen.dart
    │       └── ask_question_screen.dart
    └── profile/
        └── presentation/screens/
            ├── profile_screen.dart
            ├── my_questions_screen.dart
            └── bookmarks_screen.dart
```

---

## Setup Guide

### 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project.
2. Under **Authentication → Providers**, enable:
   - **Email** (magic link / OTP)
   - **Google** OAuth (add your client ID and secret)
3. Note your project **URL** and **anon public key** from **Project Settings → API**.

### 2. Create the Database Schema

Run the following in the Supabase SQL editor:

```sql
-- Users
create table users (
  id uuid references auth.users primary key,
  email text,
  year int,
  branch text,
  display_tag text,
  role text default 'student',
  onboarding_complete boolean default false,
  joined_at timestamptz default now()
);

-- Wiki articles
create table wiki_articles (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  summary text,
  body text,
  category text,
  target_years int[],
  target_branches text[],
  is_pinned boolean default false,
  status text default 'published',
  last_verified_at timestamptz,
  updated_at timestamptz default now(),
  view_count int default 0,
  bookmark_count int default 0
);

-- Questions
create table questions (
  id uuid primary key default gen_random_uuid(),
  body text not null,
  tag text,
  author_uid uuid references users(id),
  author_tag text,
  upvotes int default 0,
  upvoted_by uuid[],
  answer_count int default 0,
  is_resolved boolean default false,
  created_at timestamptz default now()
);

-- Answers
create table answers (
  id uuid primary key default gen_random_uuid(),
  question_id uuid references questions(id) on delete cascade,
  body text not null,
  author_uid uuid references users(id),
  author_tag text,
  upvotes int default 0,
  upvoted_by uuid[],
  is_verified boolean default false,
  verified_by uuid references users(id),
  created_at timestamptz default now()
);

-- Bookmarks
create table bookmarks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade,
  article_id uuid references wiki_articles(id) on delete cascade,
  saved_at timestamptz default now(),
  unique(user_id, article_id)
);
```

### 3. Add RPC Functions

```sql
create or replace function increment_view_count(article_id uuid)
returns void as $$
  update wiki_articles set view_count = view_count + 1 where id = article_id;
$$ language sql;

create or replace function toggle_bookmark(p_user_id uuid, p_article_id uuid)
returns boolean as $$
declare
  exists_already boolean;
begin
  select exists(select 1 from bookmarks where user_id = p_user_id and article_id = p_article_id)
    into exists_already;
  if exists_already then
    delete from bookmarks where user_id = p_user_id and article_id = p_article_id;
    return false;
  else
    insert into bookmarks(user_id, article_id) values (p_user_id, p_article_id);
    return true;
  end if;
end;
$$ language plpgsql;
```

### 4. Connect Flutter to Supabase

In `lib/main.dart`, replace the placeholder credentials with your project values:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### 5. Configure Deep Links (magic link auth)

**Android** — add inside `<activity>` in `android/app/src/main/AndroidManifest.xml`:
```xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="https" android:host="YOUR_SUPABASE_PROJECT_REF.supabase.co"/>
</intent-filter>
```

**iOS** — add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.uniguide</string>
    </array>
  </dict>
</array>
```

Also set the redirect URL in Supabase **Authentication → URL Configuration**:
```
io.supabase.uniguide://login-callback
```

### 6. Install Dependencies and Run

```bash
flutter pub get
flutter run
```

---

## Data Model

### `users`
| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Matches `auth.users` |
| `email` | text | |
| `year` | int | Academic year (1–4) |
| `branch` | text | e.g. "CS", "ECE" |
| `display_tag` | text | e.g. "2nd Year CS" |
| `role` | text | `student` or `moderator` |
| `onboarding_complete` | boolean | |

### `wiki_articles`
| Column | Type | Notes |
|---|---|---|
| `title` | text | |
| `body` | text | HTML content |
| `category` | text | `exams`, `erp`, `placements`, `hostel`, `facilities` |
| `is_pinned` | boolean | |
| `status` | text | `published` or `draft` |
| `target_years` | int[] | e.g. `[1, 2]` |
| `target_branches` | text[] | e.g. `["all"]` or `["CS", "IT"]` |

### `questions` / `answers`
Both support upvotes (stored as `upvoted_by uuid[]`). Answers have `is_verified` toggled by moderators.

---

## Granting Moderator Access

Update the user's role directly in the Supabase table editor or via SQL:

```sql
update users set role = 'moderator' where email = 'mod@example.com';
```

---

## Roadmap

- [ ] Full-text search (pg_trgm or Typesense)
- [ ] Admin panel (web) for wiki editing
- [ ] Branch filter on Q&A feed
- [ ] Push notifications (weekly digest)
- [ ] Content moderation / report flow

# Supabase configuration — copy to .env and fill in values.
#
# NEVER commit .env to version control.
# The anon key is safe to use client-side ONLY because Row Level Security (RLS)
# enforces access control on the database. The service_role key must NEVER
# appear in client code or this file.
#
# Key rotation:
#   1. Generate new keys in Supabase Dashboard -> Settings -> API
#   2. Update .env with the new values
#   3. Rebuild and redeploy the app with --dart-define-from-file=.env
#   4. Revoke the old keys in Supabase Dashboard

SUPABASE_URL= 
SUPABASE_ANON_KEY= 
