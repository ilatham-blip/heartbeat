# File for connecting to the supabase
import os 
from dotenv import load_dotenv
from supabase import create_client, Client

# 1. loading the .env file
load_dotenv()

url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_SERVICE_KEY")

# 2. setting up teh supabase client
supabase: Client = create_client(url, key)

# 3. testing the connection

def test_connection():

    response = supabase.table('user_profiles').select("*").limit(5).execute()

    print("Connection Successful!")
    print("Found users:", response.data)

if __name__ == "__main__":
    test_connection()

