import streamlit as st
import pandas as pd
import plotly.express as px
from packages.supabase_client import fetch_table_data
from datetime import datetime, timedelta

def show_home(supabase):
    st.title("Welcome to Heartbeat Research")
    
    # 1. Fetch Data
    with st.spinner("Loading metrics..."):
        users_df = fetch_table_data("user_profiles", supabase)
        morning_df = fetch_table_data("morning_checkins", supabase)
        evening_df = fetch_table_data("evening_checkins", supabase)
        episodes_df = fetch_table_data("episodes", supabase)

    # 2. Key Metrics
    total_patients = len(users_df)
    
    # Calculate Adherence (Last 7 Days)
    today = datetime.now().date()
    seven_days_ago = today - timedelta(days=7)
    
    # Process Morning Checkins
    if not morning_df.empty:
        morning_df['date'] = pd.to_datetime(morning_df['date']).dt.date
        recent_morning = morning_df[morning_df['date'] >= seven_days_ago]
        morning_count = len(recent_morning)
    else:
        morning_count = 0
        
    # Process Evening Checkins
    if not evening_df.empty:
        evening_df['date'] = pd.to_datetime(evening_df['date']).dt.date
        recent_evening = evening_df[evening_df['date'] >= seven_days_ago]
        evening_count = len(recent_evening)
    else:
        evening_count = 0

    total_recent_checkins = morning_count + evening_count
    # Expected = Users * 7 days * 2 logs/day
    expected_logs = total_patients * 7 * 2
    adherence_pct = (total_recent_checkins / expected_logs * 100) if expected_logs > 0 else 0

    # Process Episodes (Last 7 Days)
    if not episodes_df.empty:
        # Check if 'date' allows string or datetime comparison (Schema says it's strictly 'date' type)
        episodes_df['date'] = pd.to_datetime(episodes_df['date']).dt.date
        recent_episodes = episodes_df[episodes_df['date'] >= seven_days_ago]
        episodes_count = len(recent_episodes)
    else:
        episodes_count = 0

    # Display Metrics
    col1, col2, col3 = st.columns(3)
    col1.metric("Active Patients", total_patients)
    col2.metric("7-Day Adherence", f"{adherence_pct:.1f}%", help="Completed Morning/Evening quizzes over expected total for past week")
    col3.metric("Episodes (Past Week)", episodes_count)

    st.divider()

    # 3. Carousel of Charts
    st.subheader("Study Trends")

    # Chart 1: Check-ins over time
    chart1 = None
    if not morning_df.empty or not evening_df.empty:
        # Combine counts
        m_counts = pd.DataFrame()
        e_counts = pd.DataFrame()
        
        if not morning_df.empty:
            m_counts = morning_df.groupby('date').size().reset_index(name='Morning')
        
        if not evening_df.empty:
            e_counts = evening_df.groupby('date').size().reset_index(name='Evening')
            
        if not m_counts.empty and not e_counts.empty:
            combined = pd.merge(m_counts, e_counts, on='date', how='outer').fillna(0)
        elif not m_counts.empty:
            combined = m_counts
            combined['Evening'] = 0
        else:
            combined = e_counts
            combined['Morning'] = 0
            
        if 'Morning' in combined.columns and 'Evening' in combined.columns:
             chart1 = px.bar(combined, x='date', y=['Morning', 'Evening'], title="Daily Check-ins (Network Wide)")
        elif 'Morning' in combined.columns:
             chart1 = px.bar(combined, x='date', y='Morning', title="Daily Morning Check-ins")
        else:
             chart1 = px.bar(combined, x='date', y='Evening', title="Daily Evening Check-ins")


    # Chart 2: Episodes over time
    chart2 = None
    if not episodes_df.empty:
        episode_counts = episodes_df.groupby('date').size().reset_index(name='count')
        chart2 = px.line(episode_counts, x='date', y='count', title="Daily POTS Episodes Reported", markers=True)

    # Chart 3: Fatigue Distribution (Morning vs Evening)
    chart3 = None
    # Morning: 'fatigue' (0-3), Evening: 'fatigue_score' (0-3)
    fatigue_data = []
    
    if not morning_df.empty and 'fatigue' in morning_df.columns:
        for val in morning_df['fatigue'].dropna():
            fatigue_data.append({'Type': 'Morning', 'Level': val})

    if not evening_df.empty and 'fatigue_score' in evening_df.columns:
        for val in evening_df['fatigue_score'].dropna():
             fatigue_data.append({'Type': 'Evening', 'Level': val})
             
    if fatigue_data:
        f_df = pd.DataFrame(fatigue_data)
        chart3 = px.histogram(f_df, x="Level", color="Type", barmode='group', title="Distribution of Fatigue Levels", nbins=4)


    # Carousel Logic
    if 'carousel_index' not in st.session_state:
        st.session_state.carousel_index = 0

    charts = [c for c in [chart1, chart2, chart3] if c is not None]
    
    if charts:
        # Display current chart
        st.plotly_chart(charts[st.session_state.carousel_index], use_container_width=True)
        
        # Navigation buttons for carousel
        c_prev, c_next = st.columns([1, 10])
        with c_prev:
            if st.button("Previous"):
                st.session_state.carousel_index = (st.session_state.carousel_index - 1) % len(charts)
                st.rerun() 
        with st.container(): 
            if st.button("Next Chart"):
                 st.session_state.carousel_index = (st.session_state.carousel_index + 1) % len(charts)
                 st.rerun()
    else:
        st.info("Not enough data to generate charts.")

    st.divider()

    # 4. Button to Navigation
    if st.button("Go to Data Dashboard", type="primary"):
        st.session_state.page_selection = "Data Dashboard"
        st.rerun()
