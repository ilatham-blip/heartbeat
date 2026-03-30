import streamlit as st

# ── Shared light-mode CSS for all auth pages ────────────────────────────────
AUTH_CSS = """
<style>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');
@import url('https://fonts.googleapis.com/icon?family=Material+Icons');

/* --- Typography: Targeted Inter font without breaking icons --- */
.stApp, .stText, .stMarkdown, p, h1, h2, h3, h4, h5, h6, li, label, input, button, select, textarea {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif !important;
}
/* Ensure icons keep their font */
[data-testid="stIcon"], .material-icons, .material-symbols-outlined {
    font-family: 'Material Icons' !important;
}
*, *::before, *::after {
    box-sizing: border-box;
}

/* ── Flat white background ───────────────────────────────────────────────── */
.stApp,
html, body,
[data-testid="stAppViewContainer"],
[data-testid="stAppViewContainer"] > .main {
    background: #F4F6FA !important;
}

/* ── Hide Streamlit chrome ───────────────────────────────────────────────── */
[data-testid="stHeader"]          { background: transparent !important; border-bottom: none !important; }
section[data-testid="stSidebar"]  { display: none !important; }
#MainMenu, footer                  { visibility: hidden !important; }

/* ── Card wrapper ─────────────────────────────────────────────────────────── */
.auth-card-wrap {
    background: #FFFFFF;
    border-radius: 18px;
    padding: 2.25rem 2rem;
    box-shadow:
        0 1px 2px rgba(15, 23, 42, 0.05),
        0 4px 12px rgba(15, 23, 42, 0.06),
        0 16px 36px rgba(15, 23, 42, 0.07);
    border: 1px solid #E8ECF2;
}

/* ── Typography ───────────────────────────────────────────────────────────── */
.auth-logo-icon {
    font-size: 2.75rem;
    display: block;
    text-align: center;
    margin-bottom: 0.4rem;
    filter: drop-shadow(0 4px 8px rgba(239, 68, 68, 0.22));
}
.auth-title {
    text-align: center;
    color: #0F172A;
    font-size: 1.6rem;
    font-weight: 800;
    margin: 0;
    letter-spacing: -0.03em;
    line-height: 1.2;
}
.auth-subtitle {
    text-align: center;
    color: #94A3B8;
    font-size: 0.875rem;
    margin-top: 0.3rem;
    margin-bottom: 1.5rem;
}
.auth-divider {
    border: none;
    border-top: 1px solid #F1F5F9;
    margin: 1.2rem 0;
}
.auth-footer-link {
    text-align: center;
    color: #CBD5E1;
    font-size: 0.8rem;
    margin-top: 0.5rem;
}
.auth-section-label {
    color: #64748B;
    font-size: 0.75rem;
    font-weight: 600;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    margin-bottom: 0.5rem;
}

/* ── Input fields ─────────────────────────────────────────────────────────── */
.stTextInput > label,
.stTextArea  > label {
    color:          #374151  !important;
    font-size:      0.8rem   !important;
    font-weight:    600      !important;
    letter-spacing: 0.02em  !important;
    margin-bottom:  4px      !important;
}
.stTextInput input {
    background:  #F8FAFC           !important;
    border:      1.5px solid #E2E8F0 !important;
    border-radius: 10px            !important;
    color:       #0F172A           !important;
    font-size:   0.88rem           !important;
    padding:     0.55rem 0.85rem   !important;
    transition:  border-color 0.15s ease, box-shadow 0.15s ease, background 0.15s ease !important;
    box-shadow:  0 1px 2px rgba(0,0,0,0.04) !important;
}
.stTextInput input:focus {
    border-color: #2563EB               !important;
    background:   #FFFFFF               !important;
    box-shadow:   0 0 0 3px rgba(37,99,235,0.1), 0 1px 2px rgba(0,0,0,0.04) !important;
    outline: none !important;
}
.stTextInput input::placeholder { color: #CBD5E1 !important; }

.stTextArea textarea {
    background:    #F8FAFC           !important;
    border:        1.5px solid #E2E8F0 !important;
    border-radius: 10px              !important;
    color:         #0F172A           !important;
    font-size:     0.88rem           !important;
    transition:    border-color 0.15s ease, box-shadow 0.15s ease !important;
}
.stTextArea textarea:focus {
    border-color: #2563EB !important;
    background:   #FFFFFF !important;
    box-shadow:   0 0 0 3px rgba(37,99,235,0.1) !important;
}
.stTextArea textarea::placeholder { color: #CBD5E1 !important; }

/* ── Form submit (primary CTA) ────────────────────────────────────────────── */
.stFormSubmitButton > button {
    background:    #2563EB        !important;
    color:         #FFFFFF        !important;
    border:        none           !important;
    border-radius: 10px           !important;
    font-weight:   700            !important;
    font-size:     0.88rem        !important;
    letter-spacing: 0.02em       !important;
    padding:       0.65rem 1.25rem !important;
    box-shadow:    0 2px 8px rgba(37,99,235,0.25) !important;
    transition:    all 0.2s ease  !important;
    width:         100%           !important;
}
.stFormSubmitButton > button:hover {
    background:  #1D4ED8 !important;
    box-shadow:  0 6px 16px rgba(37,99,235,0.3) !important;
    transform:   translateY(-1px) !important;
}
.stFormSubmitButton > button:active { transform: translateY(0) !important; }

/* ── Regular buttons ──────────────────────────────────────────────────────── */
.stButton > button {
    border-radius: 10px         !important;
    font-weight:   500          !important;
    font-size:     0.87rem      !important;
    transition:    all 0.15s ease !important;
    border:        1.5px solid #E2E8F0 !important;
    color:         #475569      !important;
    background:    #FFFFFF      !important;
    box-shadow:    0 1px 2px rgba(0,0,0,0.04) !important;
}
.stButton > button:hover {
    background:   #F8FAFC  !important;
    border-color: #CBD5E1  !important;
    color:        #334155  !important;
}
.stButton > button[kind="primary"] {
    background:   #2563EB !important;
    color:        #FFFFFF !important;
    border:       none    !important;
    box-shadow:   0 2px 8px rgba(37,99,235,0.25) !important;
}
.stButton > button[kind="primary"]:hover {
    background:  #1D4ED8 !important;
    box-shadow:  0 6px 16px rgba(37,99,235,0.3) !important;
    transform:   translateY(-1px) !important;
    color:       #FFFFFF  !important;
}

/* ── Alerts ───────────────────────────────────────────────────────────────── */
.stAlert { border-radius: 10px !important; border: none !important; font-size: 0.85rem !important; }

/* ── Spinner ──────────────────────────────────────────────────────────────── */
.stSpinner > div { border-top-color: #2563EB !important; }

.v-gap { margin-top: 0.75rem; }
</style>
"""
