import streamlit as st
import pandas as pd
from packages.supabase_client import init_supabase, sign_out_researcher

# Import dashboard views
import views.home as home
import views.data_dashboard as data_dashboard
import views.more as more

# Import auth views
import views.landing as landing
import views.signup as signup
import views.auth_login as auth_login
import views.study_login as study_login
import views.create_study as create_study

# ── Page Config ─────────────────────────────────────────────────────────────
st.set_page_config(
    page_title="Heartbeat Research Dashboard",
    layout="wide",
    page_icon="❤️"
)

# ── Dashboard CSS (only shown post-auth) ────────────────────────────────────
DASHBOARD_CSS = """
<style>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');
@import url('https://fonts.googleapis.com/icon?family=Material+Icons');

/* --- Typography: Targeted Inter font without breaking icons --- */
.stApp, .stText, .stMarkdown, p, h1, h2, h3, h4, h5, h6, li, label, input, button, select, textarea {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif !important;
}
/* Ensure icons keep their font */
[data-testid="stIcon"], .material-icons, .material-symbols-outlined {
    font-family: 'Material Icons' !important; /* Fallback to Material Icons */
}

/* ── Main background ────────────────────────────────────── */
.stApp,
[data-testid="stAppViewContainer"],
[data-testid="stAppViewContainer"] > .main {
    background: #F4F6FA !important;
}

/* ── Sidebar ──────────────────────────────────────── */
section[data-testid="stSidebar"] {
    background: #FFFFFF                     !important;
    border-right: 1px solid #EAECF0         !important;
    box-shadow: 2px 0 12px rgba(15,23,42,0.04) !important;
}

/* Sidebar nav buttons */
section[data-testid="stSidebar"] div.stButton > button {
    background:    transparent  !important;
    border:        none         !important;
    border-radius: 10px         !important;
    color:         #475569      !important;
    font-weight:   500          !important;
    font-size:     0.87rem      !important;
    text-align:    left         !important;
    padding:       0.55rem 0.85rem !important;
    width:         100%         !important;
    transition:    all 0.15s ease !important;
    box-shadow:    none         !important;
}
section[data-testid="stSidebar"] div.stButton > button:hover {
    background: #EFF6FF !important;
    color:      #2563EB !important;
}

/* ── Headers ──────────────────────────────────────── */
h1 { color: #0F172A !important; font-size: 1.75rem !important; font-weight: 800 !important; letter-spacing: -0.02em !important; }
h2 { color: #1E293B !important; font-weight: 700 !important; }
h3 { color: #334155 !important; font-weight: 600 !important; }

/* ── Metrics ──────────────────────────────────────── */
div[data-testid="metric-container"] {
    background:    #FFFFFF      !important;
    border:        1px solid #E8ECF2 !important;
    border-radius: 14px         !important;
    padding:       1rem 1.25rem !important;
    box-shadow:    0 1px 3px rgba(15,23,42,0.05) !important;
}
div[data-testid="stMetricValue"] {
    color:       #2563EB !important;
    font-weight: 700     !important;
    font-size:   1.6rem  !important;
}
div[data-testid="stMetricLabel"] { color: #64748B !important; font-size: 0.8rem !important; }

/* ── DataFrames & Charts ──────────────────────────── */
.stDataFrame, iframe,
[data-testid="stPlotlyChart"] > div {
    background:    #FFFFFF   !important;
    border-radius: 14px      !important;
    border:        1px solid #E8ECF2 !important;
    box-shadow:    0 1px 3px rgba(15,23,42,0.05) !important;
    overflow:      hidden;
}

/* ── Primary buttons ────────────────────────────────── */
.stButton > button[kind="primary"],
.stFormSubmitButton > button {
    background:    #2563EB   !important;
    color:         #FFFFFF   !important;
    border:        none      !important;
    border-radius: 10px      !important;
    font-weight:   600       !important;
    box-shadow:    0 2px 8px rgba(37,99,235,0.22) !important;
    transition:    all 0.2s ease !important;
}
.stButton > button[kind="primary"]:hover,
.stFormSubmitButton > button:hover {
    background:  #1D4ED8                            !important;
    box-shadow:  0 6px 16px rgba(37,99,235,0.28)    !important;
    transform:   translateY(-1px)                   !important;
}

/* ── Dividers ──────────────────────────────────────── */
hr { border-color: #EAECF0 !important; }

/* ── Tabs ────────────────────────────────────────── */
.stTabs [data-baseweb="tab-list"] {
    background:    #F1F5F9 !important;
    border-radius: 10px    !important;
    padding:       3px     !important;
    gap:           2px     !important;
}
.stTabs [data-baseweb="tab"] {
    border-radius: 8px     !important;
    font-weight:   500     !important;
    font-size:     0.85rem !important;
    color:         #64748B !important;
}
.stTabs [aria-selected="true"] {
    background: #FFFFFF !important;
    color:      #1E293B !important;
    font-weight: 600    !important;
    box-shadow: 0 1px 3px rgba(15,23,42,0.08) !important;
}

/* ── Dev mode badge ────────────────────────────────── */
.dev-badge {
    background:    #FFF7ED;
    border:        1.5px solid #FED7AA;
    border-radius: 10px;
    padding:       0.55rem 0.8rem;
    margin-bottom: 0.75rem;
    display:       flex;
    align-items:   center;
    gap:           0.5rem;
}

/* ── Alerts ────────────────────────────────────────── */
.stAlert { border-radius: 10px !important; border: none !important; font-size: 0.85rem !important; }

/* Fix Font Awesome/Material Icons text appearing instead of icons if applicable */
.material-icons {
    font-family: 'Material Icons' !important;
}
</style>
"""

# ── Initialise Supabase ──────────────────────────────────────────────────────
try:
    supabase = init_supabase()
except Exception as e:
    st.error(f"Failed to connect to Supabase: {e}")
    st.stop()

# ── Auth Gate ────────────────────────────────────────────────────────────────
researcher = st.session_state.get("researcher")
active_study = st.session_state.get("active_study")
auth_page = st.session_state.get("auth_page", "landing")

# If not fully authenticated, show the correct auth screen
if not researcher or not active_study:
    if not researcher:
        # Not logged in at all
        if auth_page == "signup":
            signup.show_signup(supabase)
        elif auth_page == "login":
            auth_login.show_login(supabase)
        else:
            landing.show_landing()
    else:
        # Logged in but no study unlocked yet
        if auth_page == "create_study":
            create_study.show_create_study(supabase)
        elif auth_page == "study_login":
            study_login.show_study_login(supabase)
        else:
            # Determine which step they need
            study_login.show_study_login(supabase)
    st.stop()

# ── Dashboard (fully authenticated) ─────────────────────────────────────────
st.markdown(DASHBOARD_CSS, unsafe_allow_html=True)

# Get researcher info
meta = {}
if hasattr(researcher, "user_metadata"):
    meta = researcher.user_metadata or {}
display_name = meta.get("full_name", researcher.email if hasattr(researcher, "email") else "Researcher")
institution = meta.get("institution", "")
study_code = active_study.get("study_code", "N/A")
study_title = active_study.get("title", "My Study")

# Initialise page selection
if "page_selection" not in st.session_state:
    st.session_state.page_selection = "Home"

with st.sidebar:
    st.image("https://emojicdn.elk.sh/❤️", width=44)
    st.title("Heartbeat")

    st.markdown("---")

    # Dev mode banner
    is_dev = st.session_state.get("dev_mode", False)
    if is_dev:
        st.markdown("""
        <div class="dev-badge">
            <span style="font-size:1rem;">🔧</span>
            <div>
                <div style="color:#C2410C; font-size:0.72rem; font-weight:700; letter-spacing:0.04em;">DEVELOPER MODE</div>
                <div style="color:#EA580C; font-size:0.7rem;">Mock data · No DB writes</div>
            </div>
        </div>
        """, unsafe_allow_html=True)

    # Researcher info removed as requested
    pass

    # Navigation
    if st.button("🏠  Home", key="btn_home", use_container_width=True):
        st.session_state.page_selection = "Home"
        st.rerun()

    if st.button("📊  Dashboard", key="btn_dashboard", use_container_width=True):
        st.session_state.page_selection = "Data Dashboard"
        st.rerun()

    if st.button("⚙️  Admin", key="btn_more", use_container_width=True):
        st.session_state.page_selection = "More"
        st.rerun()

    st.markdown("---")

    # Logout
    if st.button("🚪  Log Out", key="btn_logout", use_container_width=True):
        if not st.session_state.get("dev_mode"):
            sign_out_researcher(supabase)
        keys_to_clear = ["researcher", "active_study", "pending_study",
                         "auth_page", "page_selection", "carousel_index", "dev_mode"]
        for k in keys_to_clear:
            st.session_state.pop(k, None)
        st.rerun()

# ── Page Routing ─────────────────────────────────────────────────────────────
page = st.session_state.page_selection

if page == "Home":
    home.show_home(supabase)
elif page == "Data Dashboard":
    data_dashboard.show_data_dashboard(supabase)
elif page == "More":
    more.show_more(supabase)
