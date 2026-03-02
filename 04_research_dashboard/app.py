import streamlit as st
import pandas as pd
from packages.supabase_client import init_supabase

# Import views
# Note: app.py is entry point, so we can import from local modules
import views.home as home
import views.data_dashboard as data_dashboard
import views.more as more

# Page Config
st.set_page_config(page_title="Heartbeat Research Dashboard", layout="wide", page_icon="❤️")

# Custom CSS for styling
st.markdown("""
<style>
    /* Main Background */
    .stApp {
        background-color: #FAFAFA;
    }
    
    /* Sidebar styling */
    section[data-testid="stSidebar"] {
        background-color: #FFFFFF;
        box-shadow: 2px 0 10px rgba(0,0,0,0.05);
        border-right: 1px solid #E5E7EB;
    }
    
    /* Card-like containers for data */
    .stDataFrame, .stPlotlyChart {
        background-color: #FFFFFF;
        padding: 1rem;
        border-radius: 12px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
    }

    /* Headers */
    h1, h2, h3 {
        color: #1E40AF;
        font-family: 'Inter', sans-serif;
    }
    
    /* Metrics */
    div[data-testid="stMetricValue"] {
        color: #1E40AF;
    }
    
    /* Custom buttons */
    button[kind="primary"] {
        background-color: #1E40AF;
        border-radius: 8px;
        border: none;
        transition: all 0.2s;
    }
    button[kind="primary"]:hover {
        background-color: #1E3A8A;
        box-shadow: 0 4px 12px rgba(30, 64, 175, 0.2);
    }
</style>
""", unsafe_allow_html=True)

# Initialize Supabase
try:
    supabase = init_supabase()
except Exception as e:
    st.error(f"Failed to connect to Supabase: {e}")
    st.stop()

# Initialize Session State
if "page_selection" not in st.session_state:
    st.session_state.page_selection = "Home"

with st.sidebar:
    st.image("https://emojicdn.elk.sh/❤️", width=50)
    st.title("Heartbeat")
    
    st.markdown("---")
    
    # Create custom navigation buttons vertically
    if st.button("🏠\nHome", key="btn_home", use_container_width=True):
        st.session_state.page_selection = "Home"
        st.rerun()
    
    if st.button("➕\nDashboard", key="btn_dashboard", use_container_width=True):
        st.session_state.page_selection = "Data Dashboard"
        st.rerun()
    
    if st.button("☰\nMore", key="btn_more", use_container_width=True):
        st.session_state.page_selection = "More"
        st.rerun()
    
    st.markdown("---")

# Routing
page = st.session_state.page_selection

if page == "Home":
    home.show_home(supabase)
elif page == "Data Dashboard":
    data_dashboard.show_data_dashboard(supabase)
elif page == "More":
    more.show_more(supabase)
