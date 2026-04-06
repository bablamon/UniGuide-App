-- ============================================================================
-- Row Level Security (RLS) policies for UniGuide
-- Run this in the Supabase SQL Editor to secure all tables.
-- ============================================================================

-- ── users ────────────────────────────────────────────────────────────────────
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Anyone authenticated can read any user profile (needed for display_tag).
CREATE POLICY "Users are viewable by authenticated users"
  ON public.users FOR SELECT
  TO authenticated
  USING (true);

-- Users can only insert/update their own row.
CREATE POLICY "Users can insert their own profile"
  ON public.users FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.users FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ── wiki_articles ────────────────────────────────────────────────────────────
ALTER TABLE public.wiki_articles ENABLE ROW LEVEL SECURITY;

-- All authenticated users can read published articles.
CREATE POLICY "Published articles are viewable by authenticated users"
  ON public.wiki_articles FOR SELECT
  TO authenticated
  USING (status = 'published');

-- Only moderators can insert/update/delete articles.
CREATE POLICY "Moderators can manage articles"
  ON public.wiki_articles FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE users.id = auth.uid() AND users.role = 'moderator'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE users.id = auth.uid() AND users.role = 'moderator'
    )
  );

-- ── questions ────────────────────────────────────────────────────────────────
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;

-- All authenticated users can read questions.
CREATE POLICY "Questions are viewable by authenticated users"
  ON public.questions FOR SELECT
  TO authenticated
  USING (true);

-- Users can only insert questions as themselves.
CREATE POLICY "Users can insert their own questions"
  ON public.questions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::text = author_uid);

-- Users can update only their own questions (for editing).
CREATE POLICY "Users can update their own questions"
  ON public.questions FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = author_uid);

-- ── answers ──────────────────────────────────────────────────────────────────
ALTER TABLE public.answers ENABLE ROW LEVEL SECURITY;

-- All authenticated users can read answers.
CREATE POLICY "Answers are viewable by authenticated users"
  ON public.answers FOR SELECT
  TO authenticated
  USING (true);

-- Users can only insert answers as themselves.
CREATE POLICY "Users can insert their own answers"
  ON public.answers FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::text = author_uid);

-- Users can update their own answers; moderators can update any (for verification).
CREATE POLICY "Users can update own answers, moderators can update any"
  ON public.answers FOR UPDATE
  TO authenticated
  USING (
    auth.uid()::text = author_uid
    OR EXISTS (
      SELECT 1 FROM public.users
      WHERE users.id = auth.uid() AND users.role = 'moderator'
    )
  );

-- ── bookmarks ────────────────────────────────────────────────────────────────
ALTER TABLE public.bookmarks ENABLE ROW LEVEL SECURITY;

-- Users can only see their own bookmarks.
CREATE POLICY "Users can view their own bookmarks"
  ON public.bookmarks FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Users can only insert their own bookmarks.
CREATE POLICY "Users can insert their own bookmarks"
  ON public.bookmarks FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Users can only delete their own bookmarks.
CREATE POLICY "Users can delete their own bookmarks"
  ON public.bookmarks FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);
