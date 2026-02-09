import streamlit as st
from supabase import create_client, Client
import pandas as pd

@st.cache_resource
def init_supabase() -> Client:
    url = st.secrets["supabase"]["SUPABASE_URL"]
    key = st.secrets["supabase"]["SUPABASE_KEY"]
    return create_client(url, key)

def fetch_table_data(table_name: str, supabase: Client):
    response = supabase.table(table_name).select("*").execute()
    return pd.DataFrame(response.data)

def fetch_user_data(user_id: str, table_name: str, supabase: Client):
    response = supabase.table(table_name).select("*").eq("user_id", user_id).execute()
    return pd.DataFrame(response.data)
