import streamlit as st
from supabase import create_client, Client
import pandas as pd
import random
import string
import hashlib
import os

@st.cache_resource
def init_supabase() -> Client:
    try:
        url = st.secrets["supabase"]["SUPABASE_URL"]
        key = st.secrets["supabase"]["SUPABASE_KEY"]
        return create_client(url, key)
    except Exception as e:
        st.error(f"Supabase secrets not found. Please check .streamlit/secrets.toml. Error: {e}")
        return None

def fetch_table_data(table_name: str, supabase: Client):
    response = supabase.table(table_name).select("*").execute()
    return pd.DataFrame(response.data)

def fetch_user_data(user_id: str, table_name: str, supabase: Client):
    response = supabase.table(table_name).select("*").eq("user_id", user_id).execute()
    return pd.DataFrame(response.data)

# --- Password Hashing ---

def hash_password(password: str) -> str:
    """Hashes a password using PBKDF2-HMAC-SHA256 with a random salt."""
    salt = os.urandom(32)
    key = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt, 200_000)
    return salt.hex() + ":" + key.hex()

def check_password(password: str, stored_hash: str) -> bool:
    """Verifies a password against its stored hash."""
    try:
        salt_hex, key_hex = stored_hash.split(":")
        salt = bytes.fromhex(salt_hex)
        key = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt, 200_000)
        return key.hex() == key_hex
    except Exception:
        return False

# --- Researcher Auth ---

def sign_up_researcher(email: str, password: str, full_name: str, institution: str, supabase: Client):
    """Registers a new researcher with Supabase Auth."""
    try:
        response = supabase.auth.sign_up({
            "email": email,
            "password": password,
            "options": {
                "data": {
                    "full_name": full_name,
                    "institution": institution,
                }
            }
        })
        return response.user, None
    except Exception as e:
        return None, str(e)

def sign_in_researcher(email: str, password: str, supabase: Client):
    """Signs in a researcher with email and password."""
    try:
        response = supabase.auth.sign_in_with_password({"email": email, "password": password})
        return response.user, None
    except Exception as e:
        return None, str(e)

def sign_out_researcher(supabase: Client):
    """Signs out the current researcher."""
    try:
        supabase.auth.sign_out()
    except Exception:
        pass

# --- Study Management ---

def generate_study_code():
    """Generates a unique 6-digit study code."""
    return ''.join(random.choices(string.digits, k=6))

def get_researcher_study(researcher_id: str, supabase: Client):
    """Fetches the study belonging to a given researcher. Returns dict or None."""
    try:
        response = supabase.table("research_studies").select("*").eq("researcher_id", researcher_id).execute()
        return response.data[0] if response.data else None
    except Exception as e:
        st.error(f"Error fetching study: {e}")
        return None

def create_study_for_researcher(title: str, description: str, study_password: str, researcher_id: str, supabase: Client):
    """Creates a new study for the researcher. Returns the study dict or None."""
    code = generate_study_code()
    hashed_pw = hash_password(study_password)
    data = {
        "title": title,
        "description": description,
        "study_code": code,
        "study_password": hashed_pw,
        "researcher_id": researcher_id,
        "status": "recruiting"
    }
    try:
        response = supabase.table("research_studies").insert(data).execute()
        return response.data[0] if response.data else None
    except Exception as e:
        st.error(f"Error creating study: {e}")
        return None

def verify_study_credentials(study_code: str, study_password: str, supabase: Client):
    """Verifies study code + password. Returns the study dict or None."""
    try:
        response = supabase.table("research_studies").select("*").eq("study_code", study_code).execute()
        if not response.data:
            return None, "Study code not found."
        study = response.data[0]
        stored_hash = study.get("study_password", "")
        if not stored_hash or not check_password(study_password, stored_hash):
            return None, "Incorrect study password."
        return study, None
    except Exception as e:
        return None, str(e)

def update_study(study_id: str, updates: dict, supabase: Client):
    try:
        response = supabase.table("research_studies").update(updates).eq("study_id", study_id).execute()
        return response.data
    except Exception as e:
        st.error(f"Error updating study: {e}")
        return None

# --- Patient Management ---

def update_patient_status(user_id: str, status: str, supabase: Client):
    """Updates user profile status (active, withdrawn, completed)."""
    try:
        response = supabase.table("user_profiles").update({"status": status}).eq("id", user_id).execute()
        return response.data
    except Exception as e:
        st.error(f"Error updating patient status: {e}")
        return None
