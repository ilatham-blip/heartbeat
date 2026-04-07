from supabase import create_client
import toml

secrets = toml.load(".streamlit/secrets.toml")
url = secrets["supabase"]["SUPABASE_URL"]
key = secrets["supabase"]["SUPABASE_KEY"]

supabase = create_client(url, key)
res = supabase.table("user_profiles").select("*").execute()
print(f"Total user_profiles: {len(res.data)}")
