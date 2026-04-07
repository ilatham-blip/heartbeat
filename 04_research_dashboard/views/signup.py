import streamlit as st
from packages.supabase_client import sign_up_researcher
from views.auth_styles import AUTH_CSS


def show_signup(supabase):
    st.markdown(AUTH_CSS, unsafe_allow_html=True)

    _, col, _ = st.columns([1, 1.4, 1])
    with col:
        st.markdown("""
        <div style="text-align:center; margin-bottom:1.5rem;">
            <span class="auth-logo-icon"></span>
            <h2 class="auth-title">Create your account</h2>
            <p class="auth-subtitle">Join the Heartbeat research platform</p>
        </div>
        """, unsafe_allow_html=True)

        st.markdown('<div class="auth-card-wrap">', unsafe_allow_html=True)

        with st.form("signup_form", clear_on_submit=False):
            full_name  = st.text_input("Full Name", placeholder="Dr. Jane Smith")
            institution = st.text_input("Institution / University",
                                        placeholder="e.g. University College London")
            email      = st.text_input("Email Address",
                                        placeholder="jane@university.ac.uk")

            st.markdown('<hr class="auth-divider">', unsafe_allow_html=True)
            st.markdown("""
            <p class="auth-section-label">Set a password</p>
            """, unsafe_allow_html=True)

            password         = st.text_input("Password", type="password",
                                              placeholder="At least 8 characters")
            confirm_password = st.text_input("Confirm Password", type="password",
                                              placeholder="Repeat password")

            submitted = st.form_submit_button(
                "Create Account", use_container_width=True, type="primary"
            )

        st.markdown("</div>", unsafe_allow_html=True)

        if submitted:
            if not full_name or not institution or not email or not password:
                st.error("Please fill in all fields.")
            elif len(password) < 8:
                st.error("Password must be at least 8 characters.")
            elif password != confirm_password:
                st.error("Passwords do not match.")
            else:
                with st.spinner("Creating your account…"):
                    user, error = sign_up_researcher(
                        email=email,
                        password=password,
                        full_name=full_name,
                        institution=institution,
                        supabase=supabase,
                    )
                if error:
                    st.error(f"Sign up failed: {error}")
                elif user:
                    st.session_state.researcher = user
                    st.session_state.auth_page  = "create_study"
                    st.success("Account created! Let's set up your study.")
                    st.rerun()
                else:
                    st.info("Almost there — check your email to confirm your address, then log in.")

        st.markdown('<div class="v-gap"></div>', unsafe_allow_html=True)
        if st.button("← Back to home", key="signup_back", use_container_width=True):
            st.session_state.auth_page = "landing"
            st.rerun()

        st.markdown("""
        <p class="auth-footer-link">Already have an account?
            Use <strong>Log In</strong> on the previous screen.
        </p>
        """, unsafe_allow_html=True)
