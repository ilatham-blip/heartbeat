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
  
  -- Mental Health Baseline (HADS - Hospital Anxiety and Depression Scale)
  hads_anxiety_score integer CHECK (hads_anxiety_score BETWEEN 0 AND 21),
  hads_depression_score integer CHECK (hads_depression_score BETWEEN 0 AND 21),
  hads_total_score integer CHECK (hads_total_score BETWEEN 0 AND 42)
);

-- --------------------------------------------------------
-- 2. MORNING CHECK-INS (5am - 5pm)
-- --------------------------------------------------------
CREATE TABLE public.morning_checkins (
    checkin_id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.user_profiles(id) NOT NULL,
    date date DEFAULT CURRENT_DATE,
    created_at timestamptz DEFAULT now(),

    -- Sleep (0=Awful, 1=Bad, 2=Fair, 3=Good)
    sleep_quality int CHECK (sleep_quality BETWEEN 0 AND 3),
    
    -- Symptoms (0=None, 1=Slight, 2=Moderate, 3=Severe)
    fatigue int CHECK (fatigue BETWEEN 0 AND 3),
    dizziness int CHECK (dizziness BETWEEN 0 AND 3),
    tachycardia int CHECK (tachycardia BETWEEN 0 AND 3),
    
    notes text,

    -- CONSTRAINT: One Morning log per user per day.
    UNIQUE(user_id, date)
);

-- --------------------------------------------------------
-- 3. EVENING CHECK-INS (5pm - 5am)
-- --------------------------------------------------------
CREATE TABLE public.evening_checkins (
    checkin_id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.user_profiles(id) NOT NULL,
    date date DEFAULT CURRENT_DATE,
    created_at timestamptz DEFAULT now(),

    -- Measurements
    heart_rate int,
    hrv int,
    
    -- Fatigue (0=None, 1=Slight, 2=Moderate, 3=Severe)
    fatigue_score int CHECK (fatigue_score BETWEEN 0 AND 3),
    
    -- Selected Symptoms (List of strings)
    symptoms text[], 
    
    notes text,

    -- CONSTRAINT: One Evening log per user per day.
    UNIQUE(user_id, date)
);

-- --------------------------------------------------------
-- 4. LIFESTYLE LOGS (Behavior & Triggers)
-- --------------------------------------------------------
CREATE TABLE public.lifestyle_logs (
    log_id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.user_profiles(id) NOT NULL,
    date date DEFAULT CURRENT_DATE,
    created_at timestamptz DEFAULT now(),
    
    hot_place boolean DEFAULT false,
    refined_carbs boolean DEFAULT false,
    standing_mins int,
    carbs_grams int,
    water_litres float,
    alcohol_units int,
    rest_too_much boolean DEFAULT false,
    
    ex_mild int,
    ex_moderate int,
    ex_intense int,
    
    on_period boolean DEFAULT false,
    
    stress_level int CHECK (stress_level BETWEEN 0 AND 3),
    notes text,

    UNIQUE(user_id, date)
);

-- --------------------------------------------------------
-- 5. POTS EPISODES (Attack Tracker)
-- --------------------------------------------------------
CREATE TABLE public.episodes (
    episode_id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.user_profiles(id) NOT NULL,
    date date,
    time time,
    created_at timestamptz DEFAULT now(),
    
    -- Store symptom scores as JSONB for flexibility
    -- e.g. {"Dizziness": 2, "Headache": 1}
    scores jsonb,
    
    notes text
);

-- --------------------------------------------------------
-- 6. MEASUREMENTS (Hardware Data)
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
CREATE INDEX idx_morning_user ON public.morning_checkins(user_id);
CREATE INDEX idx_evening_user ON public.evening_checkins(user_id);
CREATE INDEX idx_episodes_user ON public.episodes(user_id);
CREATE INDEX idx_lifestyle_user ON public.lifestyle_logs(user_id);

-- Speed up filtering by Time (e.g. "Show me last week's data")
CREATE INDEX idx_measurements_time ON public.measurements(recorded_at);
CREATE INDEX idx_morning_date ON public.morning_checkins(date);
CREATE INDEX idx_evening_date ON public.evening_checkins(date);
CREATE INDEX idx_episodes_date ON public.episodes(date);
CREATE INDEX idx_lifestyle_date ON public.lifestyle_logs(date);

-- Speed up Study Code lookups (Critical for signup speed)
CREATE INDEX idx_study_code ON public.research_studies(study_code);