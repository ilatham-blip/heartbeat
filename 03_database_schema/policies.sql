-- ========================================================
-- STEP 1: TURN ON THE SECURITY SYSTEM
-- ========================================================
-- Lock down the core tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.morning_checkins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evening_checkins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lifestyle_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.episodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.measurements ENABLE ROW LEVEL SECURITY;

-- Lock down the NEW tables
ALTER TABLE public.consent_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.research_studies ENABLE ROW LEVEL SECURITY;

-- ========================================================
-- STEP 2: DEFINE THE RULES (POLICIES)
-- ========================================================

-- --------------------------------------------------------
-- 1. USER PROFILES
-- --------------------------------------------------------
CREATE POLICY "Users view own profile" ON public.user_profiles
FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users update own profile" ON public.user_profiles
FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users insert own profile" ON public.user_profiles
FOR INSERT WITH CHECK (auth.uid() = id);


-- --------------------------------------------------------
-- 2. MORNING CHECK-INS
-- --------------------------------------------------------
CREATE POLICY "Users view own morning checkins" ON public.morning_checkins
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users create own morning checkins" ON public.morning_checkins
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users update own morning checkins" ON public.morning_checkins
FOR UPDATE USING (auth.uid() = user_id);


-- --------------------------------------------------------
-- 3. EVENING CHECK-INS
-- --------------------------------------------------------
CREATE POLICY "Users view own evening checkins" ON public.evening_checkins
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users create own evening checkins" ON public.evening_checkins
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users update own evening checkins" ON public.evening_checkins
FOR UPDATE USING (auth.uid() = user_id);


-- --------------------------------------------------------
-- 4. LIFESTYLE LOGS
-- --------------------------------------------------------
CREATE POLICY "Users view own lifestyle" ON public.lifestyle_logs
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users insert own lifestyle" ON public.lifestyle_logs
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users update own lifestyle" ON public.lifestyle_logs
FOR UPDATE USING (auth.uid() = user_id);


-- --------------------------------------------------------
-- 5. POTS EPISODES
-- --------------------------------------------------------
CREATE POLICY "Users view own episodes" ON public.episodes
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users insert own episodes" ON public.episodes
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users update own episodes" ON public.episodes
FOR UPDATE USING (auth.uid() = user_id);


-- --------------------------------------------------------
-- 6. MEASUREMENTS
-- --------------------------------------------------------
CREATE POLICY "Users view own measurements" ON public.measurements
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users insert own measurements" ON public.measurements
FOR INSERT WITH CHECK (auth.uid() = user_id);
-- Note: No UPDATE policy. Only the Python backend (Service Role) can update results.


-- --------------------------------------------------------
-- 7. CONSENT LOGS (New)
-- --------------------------------------------------------
-- Users can see their own consent history.
CREATE POLICY "Users view own consent" ON public.consent_logs
FOR SELECT USING (auth.uid() = user_id);

-- Users can sign a new consent form.
CREATE POLICY "Users sign consent" ON public.consent_logs
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- CRITICAL: NO UPDATE POLICY.
-- Once a legal consent form is signed, it should never be modified.


-- --------------------------------------------------------
-- 8. RESEARCH STUDIES (New)
-- --------------------------------------------------------
-- Everyone needs to read this table to check if a study code is valid.
-- 'true' means the door is open for reading to everyone (even without logging in, if needed).
CREATE POLICY "Public read access for studies" ON public.research_studies
FOR SELECT USING (true);

-- CRITICAL: NO INSERT/UPDATE POLICY.
-- Regular users can never create or edit a research study. 
-- Only you (the admin) can do this via the Supabase Dashboard.