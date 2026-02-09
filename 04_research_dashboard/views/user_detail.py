import streamlit as st
import pandas as pd
import plotly.express as px
from packages.supabase_client import fetch_table_data

def show_user_detail(user_id: str, supabase):
    st.markdown(f"### User Details: `{user_id}`")
    
    # 1. Fetch Data specific to this user
    # We can use the helper `fetch_table_data` and filter in pandas, 
    # OR create a specific query function. 
    # For now, let's query directly for efficiency.
    
    user_profile = supabase.table("user_profiles").select("*").eq("id", user_id).execute()
    checkins = supabase.table("daily_checkins").select("*").eq("user_id", user_id).order("date").execute()
    episodes = supabase.table("pots_episodes").select("*").eq("user_id", user_id).order("recorded_at").execute()
    measurements = supabase.table("measurements").select("*").eq("user_id", user_id).order("recorded_at").execute()
    
    profile_data = user_profile.data[0] if user_profile.data else {}
    checkins_df = pd.DataFrame(checkins.data)
    episodes_df = pd.DataFrame(episodes.data)
    measurements_df = pd.DataFrame(measurements.data)
    
    # --- Profile Section ---
    with st.expander("Patient Profile", expanded=True):
        c1, c2, c3 = st.columns(3)
        c1.write(f"**Email:** {profile_data.get('email', 'N/A')}")
        c1.write(f"**Age:** {profile_data.get('age', 'N/A')}")
        c1.write(f"**Gender:** {profile_data.get('gender', 'N/A')}")
        
        c2.write(f"**Study Code:** {profile_data.get('research_study_code', 'N/A')}")
        c2.write(f"**HADS Anxiety:** {profile_data.get('hads_anxiety_score', 'N/A')}")
        c2.write(f"**HADS Depression:** {profile_data.get('hads_depression_score', 'N/A')}")
        
        c3.write(f"**Comorbidities:** {', '.join(profile_data.get('comorbidities', []) or [])}")
        c3.write(f"**Medications:** {profile_data.get('medications', 'N/A')}")

    # --- Charts Section ---
    st.markdown("#### Trends")
    
    tab1, tab2, tab3 = st.tabs(["Symptom Logs", "POTS Episodes", "Measurements"])
    
    with tab1:
        if not checkins_df.empty:
            st.write("Daily Check-ins")
            # Convert date
            checkins_df['date'] = pd.to_datetime(checkins_df['date'])
            
            # Melt for easier plotting of multiple symptoms
            symptoms = ['fatigue_level', 'dizziness_level', 'heart_sensation_level', 'chest_pain_level', 'headache_level']
            # Filter cols that exist
            cols_to_plot = [c for c in symptoms if c in checkins_df.columns]
            
            if cols_to_plot:
                fig = px.line(checkins_df, x='date', y=cols_to_plot, title="Symptom Severity Over Time", markers=True)
                st.plotly_chart(fig, use_container_width=True)
            
            st.dataframe(checkins_df)
        else:
            st.info("No daily check-ins recorded.")
            
    with tab2:
        if not episodes_df.empty:
            st.write("POTS Episodes")
            episodes_df['recorded_at'] = pd.to_datetime(episodes_df['recorded_at'])
            
            # Scatter plot of episodes over time, perhaps size by severity (if we had a total severity score)
            # For now, just plot occurence
            fig = px.scatter(episodes_df, x='recorded_at', y='dizziness_upright', title="Episodes Recorded (Dizziness Level)", size='dizziness_upright')
            st.plotly_chart(fig, use_container_width=True)
            
            st.dataframe(episodes_df)
        else:
            st.info("No POTS episodes recorded.")
            
    with tab3:
        if not measurements_df.empty:
            st.write("Device Measurements")
            measurements_df['recorded_at'] = pd.to_datetime(measurements_df['recorded_at'])
            
            if 'heart_rate' in measurements_df.columns:
                fig = px.line(measurements_df, x='recorded_at', y='heart_rate', title="Heart Rate (BPM)", markers=True)
                st.plotly_chart(fig, use_container_width=True)
            
            st.dataframe(measurements_df)
        else:
            st.info("No device measurements uploaded.")
