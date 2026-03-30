import streamlit as st
from types import SimpleNamespace
from views.auth_styles import AUTH_CSS


# ── Mock data for dev bypass ─────────────────────────────────────────────────
_DEV_RESEARCHER = SimpleNamespace(
    id="dev-0000-0000-0000-000000000000",
    email="dev@heartbeat.dev",
    user_metadata={
        "full_name": "Developer",
        "institution": "Heartbeat Dev Team",
    },
)

_DEV_STUDY = {
    "study_id": "dev-study-0000-0000-0000-000000000000",
    "title": "Developer Preview Study",
    "description": "Synthetic study used for front-end development and UI testing.",
    "study_code": "000000",
    "status": "active",
    "researcher_id": "dev-0000-0000-0000-000000000000",
    "created_at": "2025-01-01T00:00:00",
    "principal_investigators": "Dr. Jane Smith, Dr. John Doe",
    "affiliated_organization": "Heartbeat University Medical Center",
    "contact_email": "research@heartbeat.dev",
    "ethics_approval_id": "IRB-2025-001",
    "start_date": "2025-01-01",
    "end_date": "2025-12-31",
}


def _activate_dev_mode():
    st.session_state.researcher   = _DEV_RESEARCHER
    st.session_state.active_study = _DEV_STUDY
    st.session_state.dev_mode     = True


def show_landing():
    st.markdown(AUTH_CSS, unsafe_allow_html=True)
    st.markdown("""
    <style>
    .landing-card {
        background: #FFFFFF;
        border-radius: 20px;
        padding: 2.5rem 2rem 2rem 2rem;
        box-shadow:
            0 1px 2px rgba(15,23,42,0.05),
            0 4px 12px rgba(15,23,42,0.06),
            0 20px 48px rgba(15,23,42,0.07);
        border: 1px solid #E8ECF2;
        text-align: center;
    }
    .brand-icon {
        font-size: 3.25rem;
        display: block;
        margin-bottom: 0.6rem;
        filter: drop-shadow(0 6px 14px rgba(239,68,68,0.22));
    }
    .brand-name {
        color: #0F172A;
        font-size: 2rem;
        font-weight: 800;
        letter-spacing: -0.04em;
        margin: 0;
        line-height: 1;
    }
    .brand-tagline {
        color: #94A3B8;
        font-size: 0.875rem;
        margin-top: 0.4rem;
        margin-bottom: 2rem;
    }
    .option-card {
        background: #FFFFFF;
        border-radius: 14px;
        padding: 1.25rem 1rem;
        text-align: center;
        margin-bottom: 0.75rem;
        border: 1.5px solid #E8ECF2;
    }
    .option-title  { font-weight: 700; font-size: 0.95rem; margin-bottom: 0.2rem; }
    .option-desc   { font-size: 0.75rem; color: #94A3B8; }
    .footer-note {
        color: #CBD5E1;
        font-size: 0.72rem;
        text-align: center;
        margin-top: 1.25rem;
        letter-spacing: 0.06em;
        text-transform: uppercase;
    }
    /* Dev button pill */
    div[data-testid="stButton"]:has(button[data-testid="dev_login_btn"]) button {
        background:    #FFFFFF     !important;
        border:        1.5px solid #E8ECF2 !important;
        border-radius: 999px       !important;
        color:         #94A3B8     !important;
        font-size:     0.72rem     !important;
        font-weight:   600         !important;
        padding:       0.3rem 0.8rem !important;
        letter-spacing: 0.04em    !important;
        box-shadow:    none        !important;
    }
    div[data-testid="stButton"]:has(button[data-testid="dev_login_btn"]) button:hover {
        background:   #F8FAFC  !important;
        border-color: #CBD5E1  !important;
        color:        #64748B  !important;
        transform:    none     !important;
    }
    </style>
    """, unsafe_allow_html=True)

    # ── Dev login — top right ─────────────────────────────────────────────────
    _, dev_col = st.columns([5.5, 1])
    with dev_col:
        if st.button("🔧 Dev", key="dev_login_btn", help="Developer preview — bypasses auth"):
            _activate_dev_mode()
            st.rerun()

    # ── Hero card ─────────────────────────────────────────────────────────────
    _, col, _ = st.columns([1, 1.4, 1])
    with col:
        st.markdown("""
        <div class="landing-card">
            <span class="brand-icon">❤️</span>
            <h1 class="brand-name">Heartbeat</h1>
            <p class="brand-tagline">Researcher Portal &middot; Cardiac Research Platform</p>
        </div>
        """, unsafe_allow_html=True)

        st.markdown("<div style='height:1rem'></div>", unsafe_allow_html=True)

        c1, c2 = st.columns(2, gap="medium")

        with c1:
            st.markdown("""
            <div class="option-card">
                <div style="font-size:1.5rem; margin-bottom:0.4rem;">📝</div>
                <div class="option-title" style="color:#1D4ED8;">New Researcher</div>
                <div class="option-desc">Register &amp; set up your study</div>
            </div>
            """, unsafe_allow_html=True)
            if st.button("Sign Up", key="btn_signup", use_container_width=True, type="primary"):
                st.session_state.auth_page = "signup"
                st.rerun()

        with c2:
            st.markdown("""
            <div class="option-card">
                <div style="font-size:1.5rem; margin-bottom:0.4rem;">🔑</div>
                <div class="option-title" style="color:#059669;">Existing Researcher</div>
                <div class="option-desc">Log in to access your study</div>
            </div>
            """, unsafe_allow_html=True)
            if st.button("Log In", key="btn_login", use_container_width=True):
                st.session_state.auth_page = "login"
                st.rerun()

        st.markdown('<p class="footer-note">Heartbeat · Secure Research Access</p>',
                    unsafe_allow_html=True)
