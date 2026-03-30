import streamlit as st
from packages.supabase_client import verify_study_credentials
from views.auth_styles import AUTH_CSS


def show_study_login(supabase):
    st.markdown(AUTH_CSS, unsafe_allow_html=True)

    pending_study = st.session_state.get("pending_study", {})
    researcher    = st.session_state.get("researcher")
    known_code    = pending_study.get("study_code", "")

    _, col, _ = st.columns([1, 1.4, 1])
    with col:
        st.markdown("""
        <div style="text-align:center; margin-bottom:1.5rem;">
            <span class="auth-logo-icon">🔐</span>
            <h2 class="auth-title">Log in to your Study</h2>
            <p class="auth-subtitle">Enter your study password to access the dashboard</p>
        </div>
        """, unsafe_allow_html=True)

        st.markdown('<div class="auth-card-wrap">', unsafe_allow_html=True)

        # Study code pill (read-only if known)
        if known_code:
            st.markdown(f"""
            <div style="
                background: linear-gradient(135deg,#EFF6FF,#EEF2FF);
                border: 1.5px solid #BFDBFE;
                border-radius: 12px;
                padding: 0.85rem 1rem;
                margin-bottom: 1rem;
                display: flex;
                align-items: center;
                gap: 0.75rem;
            ">
                <div style="font-size:1.25rem;">🔬</div>
                <div>
                    <div style="color:#64748B; font-size:0.7rem; font-weight:600; letter-spacing:0.06em; text-transform:uppercase;">Study Code</div>
                    <div style="color:#1D4ED8; font-size:1.15rem; font-weight:800; letter-spacing:0.12em;">{known_code}</div>
                </div>
            </div>
            """, unsafe_allow_html=True)

        with st.form("study_login_form", clear_on_submit=False):
            if not known_code:
                study_code_input = st.text_input("Study Code", placeholder="6-digit code")
            else:
                study_code_input = known_code

            study_password = st.text_input(
                "Study Password", type="password",
                placeholder="The password you set when creating this study"
            )

            submitted = st.form_submit_button(
                "Access Dashboard", use_container_width=True, type="primary"
            )

        st.markdown("</div>", unsafe_allow_html=True)

        if submitted:
            if not study_password:
                st.error("Please enter your study password.")
            else:
                with st.spinner("Verifying study credentials…"):
                    study, error = verify_study_credentials(
                        study_code_input, study_password, supabase
                    )

                if error:
                    st.error(f"Access denied: {error}")
                elif study:
                    researcher_id = researcher.id if researcher else None
                    if researcher_id and study.get("researcher_id") != researcher_id:
                        st.error("This study does not belong to your account.")
                    else:
                        st.session_state.active_study = study
                        st.session_state.pop("pending_study", None)
                        st.rerun()

        st.markdown('<div class="v-gap"></div>', unsafe_allow_html=True)
        if st.button("← Sign out & start over", key="study_back", use_container_width=True):
            for k in ["researcher", "pending_study", "active_study", "auth_page"]:
                st.session_state.pop(k, None)
            st.rerun()

        st.markdown("""
        <p class="auth-footer-link">
            🔒 Study credentials are independent of your account password.
        </p>
        """, unsafe_allow_html=True)
