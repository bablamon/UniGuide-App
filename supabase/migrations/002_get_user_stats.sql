-- ============================================================================
-- RPC: get_user_stats — returns question, answer, and bookmark counts
-- in a single round-trip instead of 3 separate queries.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_user_stats(p_uid uuid)
RETURNS json
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT json_build_object(
    'question_count', (SELECT count(*) FROM public.questions WHERE author_uid = p_uid::text),
    'answer_count',   (SELECT count(*) FROM public.answers   WHERE author_uid = p_uid::text),
    'bookmark_count', (SELECT count(*) FROM public.bookmarks WHERE user_id   = p_uid)
  );
$$;
