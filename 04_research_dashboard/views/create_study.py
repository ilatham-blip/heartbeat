import streamlit as st
import time
from packages.supabase_client import create_study_for_researcher
from views.auth_styles import AUTH_CSS


def show_create_study(supabase):
    st.markdown(AUTH_CSS, unsafe_allow_html=True)

    researcher   = st.session_state.get("researcher")
    meta         = getattr(researcher, "user_metadata", {}) or {}
    display_name = meta.get("full_name", "Researcher")

    _, col, _ = st.columns([1, 1.4, 1])
    with col:
        st.markdown(f"""
        <div style="text-align:center; margin-bottom:1.5rem;">
            <span class="auth-logo-icon">🧪</span>
            <h2 class="auth-title">Set up your Study</h2>
            <p class="auth-subtitle">Welcome, {display_name}. Let's create your research study.</p>
        </div>
        """, unsafe_allow_html=True)

        # Info banner
        st.markdown("""
        <div style="
            background: linear-gradient(135deg,#EFF6FF,#EEF2FF);
            border: 1px solid #BFDBFE;
            border-radius: 12px;
            padding: 0.85rem 1rem;
            margin-bottom: 1.25rem;
            display: flex;
            gap: 0.75rem;
            align-items: flex-start;
        ">
            <div style="font-size:1.1rem; margin-top:1px;">ℹ️</div>
            <div>
                <div style="color:#1D4ED8; font-size:0.82rem; font-weight:700; margin-bottom:0.15rem;">
                    One study per researcher
                </div>
                <div style="color:#64748B; font-size:0.78rem; line-height:1.45;">
                    Your study code is generated automatically. You'll use it alongside your
                    study password to log in each time.
                </div>
            </div>
        </div>
        """, unsafe_allow_html=True)

        st.markdown('<div class="auth-card-wrap">', unsafe_allow_html=True)

        with st.form("create_study_form", clear_on_submit=False):
            study_title = st.text_input(
                "Study Title",
                placeholder="e.g. POTS Cardiac Monitoring Study 2025"
            )
            study_description = st.text_area(
                "Description",
                placeholder="Briefly describe your study's purpose and target participants…",
                height=100,
            )

            st.markdown('<hr class="auth-divider">', unsafe_allow_html=True)
            st.markdown("""
            <p class="auth-section-label">Create a Study Password</p>
            <p style="color:#94A3B8; font-size:0.78rem; margin: -0.25rem 0 0.75rem 0;">
                You'll enter this every time you log in to your study dashboard.
            </p>
            """, unsafe_allow_html=True)

            study_password         = st.text_input("Study Password", type="password",
                                                    placeholder="Create a strong password")
            confirm_study_password = st.text_input("Confirm Study Password", type="password",
                                                    placeholder="Repeat password")

            submitted = st.form_submit_button(
                "Create Study & Enter Dashboard",
                use_container_width=True, type="primary"
            )

        st.markdown("</div>", unsafe_allow_html=True)

        if submitted:
            if not study_title or not study_password:
                st.error("Study title and password are required.")
            elif len(study_password) < 6:
                st.error("Study password must be at least 6 characters.")
            elif study_password != confirm_study_password:
                st.error("Study passwords do not match.")
            elif not researcher:
                st.error("Session expired — please log in again.")
                st.session_state.auth_page = "landing"
                st.rerun()
            else:
                with st.spinner("Creating your study…"):
                    study = create_study_for_researcher(
                        title=study_title,
                        description=study_description,
                        study_password=study_password,
                        researcher_id=researcher.id,
                        supabase=supabase,
                    )
                if study:
                    st.session_state.active_study = study
                    code = study.get("study_code", "")
                    st.success(f"✅ Study created! Your study code is **{code}** — save it somewhere safe.")
                    time.sleep(2)
                    st.rerun()
                else:
                    st.error("Failed to create study. Please try again.")

        st.markdown('<div class="v-gap"></div>', unsafe_allow_html=True)
        if st.button("← Sign out", key="create_study_back", use_container_width=True):
            for k in ["researcher", "pending_study", "active_study", "auth_page"]:
                st.session_state.pop(k, None)
            st.rerun()
