import streamlit as st
from packages.supabase_client import sign_in_researcher, get_researcher_study
from views.auth_styles import AUTH_CSS


def show_login(supabase):
    st.markdown(AUTH_CSS, unsafe_allow_html=True)

    _, col, _ = st.columns([1, 1.4, 1])
    with col:
        st.markdown("""
        <div style="text-align:center; margin-bottom:1.5rem;">
            <span class="auth-logo-icon">❤️</span>
            <h2 class="auth-title">Welcome back</h2>
            <p class="auth-subtitle">Sign in to your researcher account</p>
        </div>
        """, unsafe_allow_html=True)

        st.markdown('<div class="auth-card-wrap">', unsafe_allow_html=True)

        with st.form("login_form", clear_on_submit=False):
            email    = st.text_input("Email Address", placeholder="jane@university.ac.uk")
            password = st.text_input("Password", type="password", placeholder="Your password")

            submitted = st.form_submit_button(
                "Log In", use_container_width=True, type="primary"
            )

        st.markdown("</div>", unsafe_allow_html=True)

        if submitted:
            if not email or not password:
                st.error("Please enter your email and password.")
            else:
                with st.spinner("Signing in…"):
                    user, error = sign_in_researcher(email, password, supabase)

                if error:
                    st.error(f"Login failed: {error}")
                elif user:
                    st.session_state.researcher = user
                    existing_study = get_researcher_study(user.id, supabase)

                    if existing_study:
                        st.session_state.pending_study = existing_study
                        st.session_state.auth_page     = "study_login"
                    else:
                        st.session_state.auth_page = "create_study"

                    st.rerun()

        st.markdown('<div class="v-gap"></div>', unsafe_allow_html=True)
        if st.button("← Back to home", key="login_back", use_container_width=True):
            st.session_state.auth_page = "landing"
            st.rerun()

        st.markdown("""
        <p class="auth-footer-link">Don't have an account?
            Use <strong>Sign Up</strong> on the previous screen.
        </p>
        """, unsafe_allow_html=True)
