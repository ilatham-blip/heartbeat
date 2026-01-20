# File for connecting to the supabase
import os 
from dotenv import load_dotenv
from supabase import create_client, Client

# 1. loading the .env file
load_dotenv()

url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_SERVICE_KEY")

if not url or not key:
    print("Error: Missing keys in .env file")
    exit()

# 2. setting up teh supabase client
supabase: Client = create_client(url, key)
print(f"✅ Connected to: {url}")

# 3. testing the connection

def test_connection():
    print("\n--- 1. TESTING CONNECTION TO SUPABASE ---")

    response = supabase.table('user_profiles').select('email').limit(5).execute()

    print("Connection Successful!")
    print("Found users:", response.data)

def run_test_log():
    print("\n--- 1. CREATING FAKE USER LOG ---")

    email = "patient123456@imperial.ac.uk"
    password = "password123"


    try:
        # A. Create the User in Supabase Auth (The "Login" system)
        # We use admin.create_user to bypass email verification for testing
        user_response = supabase.auth.admin.create_user({
            "email": email,
            "password": password,
            "email_confirm": True
        })
        
        user_id = user_response.user.id
        print(f"✅ Auth User Created! ID: {user_id}")

        # B. Create the Profile in your Public Table (The "Data" system)
        # This satisfies the Foreign Key constraint
        profile_data = {
            "id": user_id,
            "email": email,
            
            "onset_trigger": "none",
            "comorbidities": ["none"],
            "is_research_participant": True
        }
        
        data = supabase.table('user_profiles').insert(profile_data).execute()
        print("✅ Profile Row Created in 'user_profiles'!")

    except Exception as e:
        print(f"Error: {e}")
        print("Note: If it says 'User already registered', that's fine! You already have a user.")


    print("\n--- 2. VERIFY WRITE ---")

    response = supabase.table('user_profiles').select("*").limit(5).execute()

    print("Connection Successful!")
    print("Found users:", response.data)



    

if __name__ == "__main__":
   run_test_log()
   #test_connection()

