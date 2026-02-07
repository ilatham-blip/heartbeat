

-- --------------------------------------------------------
-- 1. USER PROFILES 
-- --------------------------------------------------------


CREATE TABLE public.research_studies (
    study_id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at timestamptz DEFAULT now(),
    
    -- The "Key" for users to join
    study_code text NOT NULL UNIQUE CHECK (study_code ~ '^[0-9]{6}$'),
    
    -- Core Info
    title text NOT NULL,
    description text,
    status text DEFAULT 'recruiting' CHECK (status IN ('recruiting', 'active', 'closed', 'completed')),
    
    -- People & Org
    principal_investigators text[], -- Array allow multiple names: 
    affiliated_organization text,   
    contact_email text,
    
    -- Administrative / Legal
    ethics_approval_id text,        -- IRB / Ethics Board Reference Number
    start_date date DEFAULT CURRENT_DATE,
    end_date date
);


CREATE TABLE public.user_profiles (
  id uuid REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email text,
  created_at timestamptz DEFAULT now(),
  
  -- Research Access Control (Replaces boolean)
  -- This ensures the code is exactly 6 numbers (0-9)
  research_study_code text REFERENCES public.research_studies(study_code),

  -- Demographic Info
  age integer,
  gender text,
  race text,
  
  -- Medical History
  comorbidities text[],
  medications text,
  
  -- Lifestyle Baseline
  avg_alcohol_units_weekly integer,
  avg_exercise_mins_weekly integer,
  
  -- Mental Health Baseline
  mental_health_score integer
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
    
    -- File Management
    raw_file_path text,         -- Path to CSV in Supabase Storage
    source text DEFAULT 'manual', -- 'manual' or 'device_id'

    -- Calculated Metrics (Nullable because they come from Python later)
    heart_rate float,           -- BPM
    rr_interval float,          -- Mean RR Interval (ms)
    rmssd float,                -- Root Mean Square of Successive Differences (ms)
    lf float,                   -- Low Frequency Power (ms²)
    hf float,                   -- High Frequency Power (ms²)
    lf_hf_ratio float           -- Ratio of Low to High Frequency (Balance)
);




CREATE TABLE public.consent_logs (
    consent_id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.user_profiles(id) NOT NULL,
    agreed_at timestamptz DEFAULT now(),
    
    -- Version control is critical for research. 
    -- If you change the study protocol, users might need to re-consent.
    consent_version text NOT NULL, -- e.g., 'v1.0', 'v2026-A'
    
    -- What did they agree to?
    agreed_to_data_collection boolean DEFAULT false,
    agreed_to_contact boolean DEFAULT false
);


-- ========================================================
-- 7. PERFORMANCE (INDEXES)
-- ========================================================

-- Speed up filtering by User (e.g. "Show me User 123's data")
CREATE INDEX idx_measurements_user ON public.measurements(user_id);
CREATE INDEX idx_checkins_user ON public.daily_checkins(user_id);
CREATE INDEX idx_episodes_user ON public.pots_episodes(user_id);
CREATE INDEX idx_lifestyle_user ON public.lifestyle_logs(user_id);

-- Speed up filtering by Time (e.g. "Show me last week's data")
CREATE INDEX idx_measurements_time ON public.measurements(recorded_at);
CREATE INDEX idx_checkins_date ON public.daily_checkins(date);
CREATE INDEX idx_episodes_time ON public.pots_episodes(recorded_at);
CREATE INDEX idx_lifestyle_date ON public.lifestyle_logs(date);

-- Speed up Study Code lookups (Critical for signup speed)
CREATE INDEX idx_study_code ON public.research_studies(study_code);