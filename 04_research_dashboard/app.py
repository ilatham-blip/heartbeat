import streamlit as st
import pandas as pd
from packages.supabase_client import init_supabase, fetch_table_data, fetch_user_data
from views import user_detail

st.set_page_config(page_title="Heartbeat Research Dashboard", layout="wide")

supabase = init_supabase()

st.title("❤️ Heartbeat Research Dashboard")

# Navigation
st.sidebar.header("Navigation")
page = st.sidebar.radio("Go to", ["Overview", "User Explorer", "Medical Analysis"])

if page == "Overview":
    st.header("Study Overview")
    
    # Fetch high-level stats
    users_df = fetch_table_data("user_profiles", supabase)
    studies_df = fetch_table_data("research_studies", supabase)

    col1, col2, col3 = st.columns(3)
    col1.metric("Total Users", len(users_df))
    col2.metric("Active Studies", len(studies_df))
    
    # Calculate gender distribution
    if not users_df.empty and 'gender' in users_df.columns:
        st.subheader("Demographics")
        gender_counts = users_df['gender'].value_counts()
        st.bar_chart(gender_counts)
    
    # HADS scores overview
    if not users_df.empty and 'hads_total_score' in users_df.columns:
        st.subheader("HADS Total Scores Distribution")
        st.bar_chart(users_df['hads_total_score'])

elif page == "User Explorer":
    st.header("User Explorer")
    
    users_df = fetch_table_data("user_profiles", supabase)
    
    if not users_df.empty:
        # Display user table
        st.dataframe(users_df, use_container_width=True)
        
        # User selection for detailed view
        user_ids = users_df['id'].tolist()
        selected_user_id = st.selectbox("Select User ID for Detail View", [""] + user_ids)
        
        if selected_user_id:
             user_detail.show_user_detail(selected_user_id, supabase)
    else:
        st.info("No users found in the database.")

elif page == "Medical Analysis":
    st.header("Medical Analysis")
    st.write("Aggregated analysis of symptoms and measurements will go here.")
