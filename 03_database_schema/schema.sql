-- THIS FILE ALREADY BUILT THE TABLES ON THE WEBSITE
-- THIS IS JUST VERSION CONTROL/BACKUP

-- --------------------------------------------------------
-- 1. USER PROFILES (No Change)
-- --------------------------------------------------------
CREATE TABLE public.user_profiles (
    id uuid REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email text,
    created_at timestamptz DEFAULT now(),
    
    -- User Info
    comorbidities text[],
    onset_trigger text,
    is_research_participant boolean DEFAULT false
);

-- --------------------------------------------------------
-- 2. DAILY CHECK-INS (Log Type: MORNING vs EVENING)
-- --------------------------------------------------------
-- Instead of specific columns like "morning_fatigue", we use generic names.
-- The 'checkin_type' tells us if it was morning or evening.

CREATE TABLE public.daily_checkins (
    checkin_id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.user_profiles(id) NOT NULL,
    date date DEFAULT CURRENT_DATE,
    created_at timestamptz DEFAULT now(),

    -- === THE LOG TYPE ===
    -- 'MORNING' (5am-5pm) or 'EVENING' (5pm-5am)
    checkin_type text CHECK (checkin_type IN ('MORNING', 'EVENING')),

    -- === SHARED SYMPTOMS (Asked in both) ===
    -- generic names reused for both morning and evening logs
    fatigue_level int CHECK (fatigue_level BETWEEN 0 AND 3),
    dizziness_level int CHECK (dizziness_level BETWEEN 0 AND 3),
    
    -- Tachycardia (Morning) / Palpitations (Evening) - treated as same sensation
    heart_sensation_level int CHECK (heart_sensation_level BETWEEN 0 AND 3),

    -- === MORNING SPECIFIC ===
    -- Only filled if checkin_type = 'MORNING'
    sleep_quality int CHECK (sleep_quality BETWEEN 0 AND 3),

    -- === EVENING SPECIFIC ===
    -- Only filled if checkin_type = 'EVENING'
    chest_pain_level int CHECK (chest_pain_level BETWEEN 0 AND 3),
    headache_level int CHECK (headache_level BETWEEN 0 AND 3),
    concentration_diff int CHECK (concentration_diff BETWEEN 0 AND 3),
    gi_symptoms_level int CHECK (gi_symptoms_level BETWEEN 0 AND 3),
    breathing_diff int CHECK (breathing_diff BETWEEN 0 AND 3),
    temperature_change boolean, -- Abnormal hot/cold feeling

    -- CONSTRAINT: One Morning and One Evening log per user per day.
    UNIQUE(user_id, date, checkin_type)
);

-- --------------------------------------------------------
-- 3. LIFESTYLE LOGS (Behavior & Triggers)
-- --------------------------------------------------------
CREATE TABLE public.lifestyle_logs (
    log_id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.user_profiles(id) NOT NULL,
    date date DEFAULT CURRENT_DATE,
    
    exposure_to_heat boolean DEFAULT false,
    standing_duration_mins int,
    exercise_mild_mins int,
    exercise_moderate_mins int,
    exercise_intense_mins int,
    excessive_rest boolean DEFAULT false,
    
    carbs_consumed_grams int,
    fluid_intake_liters float,
    alcohol_units float,
    period_day_count int,
    
    stress_level int CHECK (stress_level BETWEEN 0 AND 3),
    personal_notes text,

    UNIQUE(user_id, date)
);

-- --------------------------------------------------------
-- 4. POTS EPISODES (Attack Tracker)
-- --------------------------------------------------------
CREATE TABLE public.pots_episodes (
    episode_id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.user_profiles(id) NOT NULL,
    recorded_at timestamptz DEFAULT now(),
    
    -- Severity of specific symptoms during the attack
    dizziness_upright int CHECK (dizziness_upright BETWEEN 0 AND 3),
    fainting_feeling int CHECK (fainting_feeling BETWEEN 0 AND 3),
    palpitations int CHECK (palpitations BETWEEN 0 AND 3),
    chest_pain int CHECK (chest_pain BETWEEN 0 AND 3),
    headache int CHECK (headache BETWEEN 0 AND 3),
    concentration_diff int CHECK (concentration_diff BETWEEN 0 AND 3),
    muscle_pain int CHECK (muscle_pain BETWEEN 0 AND 3),
    nausea int CHECK (nausea BETWEEN 0 AND 3),
    stomach_pain int CHECK (stomach_pain BETWEEN 0 AND 3),
    constipation_diarrhoea int CHECK (constipation_diarrhoea BETWEEN 0 AND 3),
    breathing_diff int CHECK (breathing_diff BETWEEN 0 AND 3)
);

-- --------------------------------------------------------
-- 5. MEASUREMENTS (Hardware Data)
-- --------------------------------------------------------
CREATE TABLE public.measurements (
    measurement_id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.user_profiles(id) NOT NULL,
    recorded_at timestamptz DEFAULT now(),
    heart_rate float,
    hrv_score float,
    raw_csv_path text,
    source text default 'manual' -- 'manual' or 'sensor'
);