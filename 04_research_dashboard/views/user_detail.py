import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots

def show_user_detail(user_id: str, supabase):
    st.markdown(f"### User Details: `{user_id}`")
    
    # 1. Fetch Data
    user_profile = supabase.table("user_profiles").select("*").eq("id", user_id).execute()
    morning = supabase.table("morning_checkins").select("*").eq("user_id", user_id).order("date").execute()
    evening = supabase.table("evening_checkins").select("*").eq("user_id", user_id).order("date").execute()
    episodes = supabase.table("episodes").select("*").eq("user_id", user_id).order("date").execute()
    measurements = supabase.table("measurements").select("*").eq("user_id", user_id).order("recorded_at").execute()
    
    profile_data = user_profile.data[0] if user_profile.data else {}
    morning_df = pd.DataFrame(morning.data)
    evening_df = pd.DataFrame(evening.data)
    episodes_df = pd.DataFrame(episodes.data)
    measurements_df = pd.DataFrame(measurements.data)
    
    # --- Profile Section ---
    with st.expander("Patient Profile", expanded=False):
        c1, c2, c3 = st.columns(3)
        c1.write(f"**User ID:** `{user_id}`")
        c1.write(f"**Age:** {profile_data.get('age', 'N/A')}")
        c1.write(f"**Gender:** {profile_data.get('gender', 'N/A')}")
        
        c2.write(f"**Study Code:** {profile_data.get('research_study_code', 'N/A')}")
        c2.write(f"**HADS Anxiety:** {profile_data.get('hads_anxiety_score', 'N/A')}")
        c2.write(f"**HADS Depression:** {profile_data.get('hads_depression_score', 'N/A')}")
        
        c3.write(f"**Comorbidities:** {', '.join(profile_data.get('comorbidities', []) or [])}")
        c3.write(f"**Medications:** {profile_data.get('medications', 'N/A')}")

        st.divider()
        st.markdown("**Export Patient Data**")
        b1, b2, b3, b4 = st.columns(4)
        if not morning_df.empty:
            b1.download_button("Morning Checkins CSV", morning_df.to_csv(index=False), f"{user_id}_morning.csv")
        if not evening_df.empty:
            b2.download_button("Evening Checkins CSV", evening_df.to_csv(index=False), f"{user_id}_evening.csv")
        if not episodes_df.empty:
            b3.download_button("Episodes CSV", episodes_df.to_csv(index=False), f"{user_id}_episodes.csv")
        if not measurements_df.empty:
            b4.download_button("Measurements CSV", measurements_df.to_csv(index=False), f"{user_id}_measurements.csv")


    # --- Charts Comparisons ---
    st.markdown("#### Symptom vs. Physiology")
    
    # Pre-process Data for Plotting
    # We need a unified date axis.
    
    # Available Symptoms
    symptom_options = {} # {Label: (df, column_name)}
    
    if not morning_df.empty:
        morning_df['date'] = pd.to_datetime(morning_df['date'])
        # Add numeric cols
        for col in ['fatigue', 'dizziness', 'tachycardia']:
            if col in morning_df.columns:
                symptom_options[f"Morning {col.replace('_', ' ').title()}"] = (morning_df, col)
                
    if not evening_df.empty:
        evening_df['date'] = pd.to_datetime(evening_df['date'])
        for col in ['fatigue_score']:
             if col in evening_df.columns:
                symptom_options[f"Evening {col.replace('_', ' ').title()}"] = (evening_df, col)

    # Physio Options
    physio_options = {}
    if not measurements_df.empty:
        measurements_df['recorded_at'] = pd.to_datetime(measurements_df['recorded_at'])
        measurements_df['date'] = measurements_df['recorded_at'].dt.date
        # Group by date for easier comparison with checkins (which are Daily)
        # Or keep as high-res. Let's keep high res but maybe smoothed?
        # For comparison with daily checkins, daily average might be best visual.
        daily_physio = measurements_df.groupby('date').agg({'heart_rate': 'mean'}).reset_index()
        daily_physio['date'] = pd.to_datetime(daily_physio['date'])
        
        physio_options["Heart Rate (Daily Avg)"] = (daily_physio, 'heart_rate')


    # Controls
    col_sel1, col_sel2 = st.columns(2)
    selected_symptom = col_sel1.selectbox("Select Symptom", options=list(symptom_options.keys()))
    selected_physio = col_sel2.selectbox("Select Physiological Metric", options=list(physio_options.keys()) + ["None"])

    # Build Chart
    if selected_symptom:
        sym_df, sym_col = symptom_options[selected_symptom]
        
        fig = make_subplots(specs=[[{"secondary_y": True}]])
        
        # Add Symptom Trace
        fig.add_trace(
            go.Scatter(x=sym_df['date'], y=sym_df[sym_col], name=selected_symptom, mode='lines+markers'),
            secondary_y=False
        )
        
        # Add Physio Trace
        if selected_physio and selected_physio != "None":
            phys_df, phys_col = physio_options[selected_physio]
            fig.add_trace(
                go.Scatter(x=phys_df['date'], y=phys_df[phys_col], name=selected_physio, mode='lines+markers', line=dict(dash='dot')),
                secondary_y=True
            )
            fig.update_yaxes(title_text=selected_physio, secondary_y=True)

        fig.update_layout(title_text=f"{selected_symptom} vs {selected_physio if selected_physio else ''}")
        fig.update_xaxes(title_text="Date")
        fig.update_yaxes(title_text="Symptom Level (0-3)", secondary_y=False)
        
        st.plotly_chart(fig, use_container_width=True)
    else:
        st.info("No symptom data available to plot.")

    # --- Episodes Timeline ---
    st.markdown("#### Episodes Timeline")
    if not episodes_df.empty:
         if 'created_at' in episodes_df.columns:
             episodes_df['Timestamp'] = pd.to_datetime(episodes_df['created_at'])
             fig_ep = px.scatter(episodes_df, x='Timestamp', y=[1]*len(episodes_df), title="Episode Occurrences", height=200)
             fig_ep.update_yaxes(visible=False, showticklabels=False)
             st.plotly_chart(fig_ep, use_container_width=True)
    else:
        st.info("No episodes recorded.")

    # --- Raw Data Tables ---
    with st.expander("View Raw Data"):
        tab1, tab2, tab3 = st.tabs(["Check-ins", "Episodes", "Measurements"])
        with tab1:
            st.write("Morning")
            st.dataframe(morning_df)
            st.write("Evening")
            st.dataframe(evening_df)
        with tab2:
            st.dataframe(episodes_df)
        with tab3:
            st.dataframe(measurements_df)
