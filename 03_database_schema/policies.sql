-- THIS FILE ALREADY BUILT THE TABLES ON THE WEBSITE
-- THIS IS JUST VERSION CONTROL/BACKUP

-- ========================================================
-- STEP 1: TURN ON THE SECURITY SYSTEM
-- ========================================================
-- By default, tables are "Open". We must lock them first.

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_checkins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lifestyle_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pots_episodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.measurements ENABLE ROW LEVEL SECURITY;

-- ========================================================
-- STEP 2: DEFINE THE RULES (POLICIES)
-- ========================================================

-- --------------------------------------------------------
-- 1. USER PROFILES
-- --------------------------------------------------------
-- Users can read their own profile.
CREATE POLICY "Users view own profile" ON public.user_profiles
FOR SELECT USING (auth.uid() = id);

-- Users can update their own medical history (e.g. toggling EDS/MCAS).
CREATE POLICY "Users update own profile" ON public.user_profiles
FOR UPDATE USING (auth.uid() = id);

-- Users can create their profile on first login.
CREATE POLICY "Users insert own profile" ON public.user_profiles
FOR INSERT WITH CHECK (auth.uid() = id);


-- --------------------------------------------------------
-- 2. DAILY CHECK-INS (Morning/Evening Logs)
-- --------------------------------------------------------
-- Users can see their own history.
CREATE POLICY "Users view own checkins" ON public.daily_checkins
FOR SELECT USING (auth.uid() = user_id);

-- Users can create a new morning log.
CREATE POLICY "Users create own checkins" ON public.daily_checkins
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update the log later (e.g. filling in the Evening section).
CREATE POLICY "Users update own checkins" ON public.daily_checkins
FOR UPDATE USING (auth.uid() = user_id);


-- --------------------------------------------------------
-- 3. LIFESTYLE LOGS
-- --------------------------------------------------------
-- Users can see their own lifestyle data.
CREATE POLICY "Users view own lifestyle" ON public.lifestyle_logs
FOR SELECT USING (auth.uid() = user_id);

-- Users can create new lifestyle entries.
CREATE POLICY "Users insert own lifestyle" ON public.lifestyle_logs
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can fix mistakes.
CREATE POLICY "Users update own lifestyle" ON public.lifestyle_logs
FOR UPDATE USING (auth.uid() = user_id);


-- --------------------------------------------------------
-- 4. POTS EPISODES (Attacks)
-- --------------------------------------------------------
-- Users can see their own episode history.
CREATE POLICY "Users view own episodes" ON public.pots_episodes
FOR SELECT USING (auth.uid() = user_id);

-- Users can log a new attack.
CREATE POLICY "Users insert own episodes" ON public.pots_episodes
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update an attack (e.g. adding symptoms after it passes).
CREATE POLICY "Users update own episodes" ON public.pots_episodes
FOR UPDATE USING (auth.uid() = user_id);


-- --------------------------------------------------------
-- 5. MEASUREMENTS (Hardware Data)
-- --------------------------------------------------------
-- Users can see their own heart data.
CREATE POLICY "Users view own measurements" ON public.measurements
FOR SELECT USING (auth.uid() = user_id);

-- Users can upload a reference to a file they uploaded.
CREATE POLICY "Users insert own measurements" ON public.measurements
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- NOTE: We generally DO NOT allow users to UPDATE measurements.
-- The Python script updates the results (HRV score), not the user.
-- So we skip the UPDATE policy here for safety.