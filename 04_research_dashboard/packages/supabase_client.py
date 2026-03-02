import streamlit as st
from supabase import create_client, Client
import pandas as pd
import random
import string

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

# --- Study Management ---

def generate_study_code():
    """Generates a random 6-digit string."""
    return ''.join(random.choices(string.digits, k=6))

def create_study(title: str, description: str, supabase: Client):
    """Creates a new study with a unique 6-digit code."""
    code = generate_study_code()
    # Ensure uniqueness (simple retry logic)
    # in prod, do a check first or handle exception
    
    data = {
        "title": title,
        "description": description,
        "study_code": code,
        "status": "recruiting"
    }
    
    try:
        response = supabase.table("research_studies").insert(data).execute()
        return response.data[0] if response.data else None
    except Exception as e:
        st.error(f"Error creating study: {e}")
        return None

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
