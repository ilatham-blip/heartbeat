import streamlit as st
import pandas as pd
from packages.supabase_client import fetch_table_data, create_study, update_study, update_patient_status

def show_more(supabase):
    st.title("Admin & Management")
    
    tab1, tab2 = st.tabs(["Study Management", "Patient Management"])
    
    # --- Study Management ---
    with tab1:
        st.header("Research Studies")
        
        # List existing
        studies_df = fetch_table_data("research_studies", supabase)
        
        if not studies_df.empty:
            st.dataframe(studies_df[['title', 'study_code', 'status', 'description', 'created_at']], use_container_width=True)
            
            st.divider()
            
            c1, c2 = st.columns(2)
            
            with c1:
                st.subheader("Edit Existing Study")
                study_titles = studies_df['title'].tolist()
                selected_study_title = st.selectbox("Select Study", study_titles)
                
                if selected_study_title:
                    study_row = studies_df[studies_df['title'] == selected_study_title].iloc[0]
                    
                    with st.form("edit_study_form"):
                        new_desc = st.text_area("Description", value=study_row.get('description', ''))
                        new_status = st.selectbox("Status", ["recruiting", "active", "closed", "completed"], index=["recruiting", "active", "closed", "completed"].index(study_row.get('status', 'recruiting')))
                        
                        if st.form_submit_button("Update Study"):
                            update_study(study_row['study_id'], {"description": new_desc, "status": new_status}, supabase)
                            st.success("Study updated!")
                            st.rerun()

            with c2:
                st.subheader("Create New Study")
                with st.form("create_study_form"):
                    new_title = st.text_input("Study Title")
                    new_desc_create = st.text_area("Description")
                    
                    if st.form_submit_button("Create Study"):
                        if new_title:
                            res = create_study(new_title, new_desc_create, supabase)
                            if res:
                                st.success(f"Study created! Code: {res['study_code']}")
                                st.rerun()
                        else:
                            st.error("Title is required.")
        else:
            st.info("No studies found. Create one below.")
            with st.form("create_first_study"):
                new_title = st.text_input("Study Title")
                new_desc_create = st.text_area("Description")
                if st.form_submit_button("Create Study"):
                     res = create_study(new_title, new_desc_create, supabase)
                     if res:
                        st.success(f"Study created! Code: {res['study_code']}")
                        st.rerun()
    
    # --- Patient Management ---
    with tab2:
        st.header("Patient Status Management")
        
        users_df = fetch_table_data("user_profiles", supabase)
        
        if not users_df.empty:
            # Display current users with status
            # If 'status' col doesn't exist yet, handle gracefully (it might not until schema update)
            cols = ['id', 'research_study_code', 'status'] if 'status' in users_df.columns else ['id', 'research_study_code']
            st.dataframe(users_df[cols], use_container_width=True)
            
            st.divider()
            
            st.subheader("Update Patient Status")
            
            # Select User
            def format_func(user_id):
                 row = users_df[users_df['id'] == user_id].iloc[0]
                 return f"{user_id} (Study: {row.get('research_study_code', 'N/A')})"
            
            user_ids = users_df['id'].tolist()
            selected_user_id = st.selectbox("Select Patient", user_ids, format_func=format_func)
            
            if selected_user_id:
                current_status = "active"
                if 'status' in users_df.columns:
                     user_row = users_df[users_df['id'] == selected_user_id].iloc[0]
                     current_status = user_row.get('status', 'active') or 'active'
                
                new_status = st.selectbox("Status", ["active", "completed", "withdrawn", "inactive"], index=["active", "completed", "withdrawn", "inactive"].index(current_status) if current_status in ["active", "completed", "withdrawn", "inactive"] else 0)
                
                if st.button("Update Status"):
                     update_patient_status(selected_user_id, new_status, supabase)
                     st.success(f"User {selected_user_id} marked as {new_status}.")
                     st.rerun()
        else:
            st.info("No patients found.")
