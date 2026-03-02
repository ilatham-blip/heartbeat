import streamlit as st
import pandas as pd
from packages.supabase_client import fetch_table_data
from views import user_detail

def show_data_dashboard(supabase):
    st.title("Data Dashboard")
    
    # 1. Toggle View Mode
    view_mode = st.radio("View Mode", ["Aggregate View", "Individual Patient View"], horizontal=True)

    if view_mode == "Aggregate View":
        st.header("Study Overview")
        
        # Fetch high-level stats
        users_df = fetch_table_data("user_profiles", supabase)
        studies_df = fetch_table_data("research_studies", supabase)
        episodes_df = fetch_table_data("episodes", supabase)

        # Download All Data Section
        with st.expander("Export Global Data"):
            st.write("Download full datasets as CSV.")
            c1, c2, c3 = st.columns(3)
            if not users_df.empty:
                c1.download_button("Download Profiles", users_df.to_csv(index=False), "user_profiles.csv", "text/csv")
            if not episodes_df.empty:
                c2.download_button("Download Episodes", episodes_df.to_csv(index=False), "episodes.csv", "text/csv")
            # We could fetch checkins here too if needed, but might be large
            # generic fetch logic above might be slow for full dump if table grows, but ok for now.

        col1, col2, col3 = st.columns(3)
        col1.metric("Total Users", len(users_df))
        col2.metric("Active Studies", len(studies_df))
        col3.metric("Total Episodes", len(episodes_df))
        
        # Calculate gender distribution
        if not users_df.empty and 'gender' in users_df.columns:
            st.subheader("Demographics")
            gender_counts = users_df['gender'].value_counts()
            st.bar_chart(gender_counts)
        
        # HADS scores overview
        if not users_df.empty and 'hads_total_score' in users_df.columns:
            st.subheader("HADS Total Scores Distribution")
            st.bar_chart(users_df['hads_total_score'])
            
        st.info("Medical Analysis aggregations would appear here.")

    elif view_mode == "Individual Patient View":
        st.header("Individual Patient Explorer")
        
        users_df = fetch_table_data("user_profiles", supabase)
        
        if not users_df.empty:
            # User selection for detailed view
            # Show User ID and Study Code if available for easier identification without PII
            def format_func(user_id):
                row = users_df[users_df['id'] == user_id].iloc[0]
                code = row.get('research_study_code', 'N/A')
                return f"{user_id} (Study Code: {code})"
            
            user_ids = users_df['id'].tolist()
            selected_user_id = st.selectbox("Select User", user_ids, format_func=format_func)
            
            if selected_user_id:
                 user_detail.show_user_detail(selected_user_id, supabase)
        else:
            st.info("No users found in the database.")
