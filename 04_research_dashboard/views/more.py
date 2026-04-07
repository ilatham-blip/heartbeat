import streamlit as st
import pandas as pd
from packages.supabase_client import fetch_table_data, update_study, update_patient_status
from datetime import datetime

def show_more(supabase):
    st.title("Admin & Management")

    tab1, tab2 = st.tabs(["Study Management", "Patient Management"])

    # --- Study Management (one study only) ---
    with tab1:
        st.header("Your Research Study")

        active_study = st.session_state.get("active_study", {})
        study_id = active_study.get("study_id")

        # Re-fetch fresh data from DB
        if study_id:
            try:
                resp = supabase.table("research_studies").select("*").eq("study_id", study_id).execute()
                study = resp.data[0] if resp.data else active_study
            except Exception:
                study = active_study
        else:
            study = active_study

        if study:
            # Study info card
            col_info, col_badge = st.columns([3, 1])
            with col_info:
                st.subheader(study.get("title", "Untitled Study"))
                st.caption(study.get("description", "No description provided."))
            with col_badge:
                status = study.get("status", "recruiting")
                badge_colours = {
                    "recruiting": ("", "#166534", "#DCFCE7"),
                    "active": ("", "#1E40AF", "#DBEAFE"),
                    "closed": ("", "#991B1B", "#FEE2E2"),
                    "completed": ("", "#374151", "#F3F4F6"),
                }
                icon, text_c, bg_c = badge_colours.get(status, ("", "#374151", "#F9FAFB"))
                st.markdown(f"""
                <div style="background:{bg_c}; color:{text_c}; border-radius:8px;
                            padding:0.4rem 0.75rem; text-align:center; font-size:0.82rem; font-weight:600;">
                    {icon} {status.capitalize()}
                </div>
                """, unsafe_allow_html=True)

            st.divider()

            # Study code display
            c1, c2, c3 = st.columns(3)
            c1.metric("Study Code", study.get("study_code", "N/A"))
            c2.metric("Status", status.capitalize())
            created = study.get("created_at", "")
            c3.metric("Created", created[:10] if created else "—")

            st.markdown("<br><h5>Administrative Details</h5>", unsafe_allow_html=True)
            r1c1, r1c2 = st.columns(2)
            r1c1.markdown(f"**Principal Investigator(s):** {study.get('principal_investigators') or '—'}")
            r1c2.markdown(f"**Affiliated Organization:** {study.get('affiliated_organization') or '—'}")

            r2c1, r2c2 = st.columns(2)
            r2c1.markdown(f"**Contact Email:** {study.get('contact_email') or '—'}")
            r2c2.markdown(f"**Ethics Approval ID:** {study.get('ethics_approval_id') or '—'}")

            r3c1, r3c2 = st.columns(2)
            r3c1.markdown(f"**Start Date:** {study.get('start_date') or '—'}")
            r3c2.markdown(f"**End Date:** {study.get('end_date') or '—'}")

            st.divider()

            # Edit form
            st.subheader("Edit Study Details")
            with st.form("edit_study_form"):
                new_desc = st.text_area("Description", value=study.get("description", ""))
                
                f_c1, f_c2 = st.columns(2)
                new_pi = f_c1.text_input("Principal Investigator(s)", value=study.get("principal_investigators", ""))
                new_org = f_c2.text_input("Affiliated Organization", value=study.get("affiliated_organization", ""))
                
                f_c3, f_c4 = st.columns(2)
                new_email = f_c3.text_input("Contact Email", value=study.get("contact_email", ""))
                new_ethics = f_c4.text_input("Ethics Approval ID", value=study.get("ethics_approval_id", ""))
                
                # Parse existing dates for the date input default value
                start_val = study.get("start_date")
                start_date_obj = datetime.strptime(start_val, "%Y-%m-%d").date() if start_val else None
                end_val = study.get("end_date")
                end_date_obj = datetime.strptime(end_val, "%Y-%m-%d").date() if end_val else None

                f_c5, f_c6 = st.columns(2)
                new_start = f_c5.date_input("Start Date", value=start_date_obj)
                new_end = f_c6.date_input("End Date", value=end_date_obj)

                status_options = ["recruiting", "active", "closed", "completed"]
                current_index = status_options.index(status) if status in status_options else 0
                new_status = st.selectbox("Status", status_options, index=current_index)

                if st.form_submit_button("Save Changes", type="primary"):
                    updates = {
                        "description": new_desc,
                        "status": new_status,
                        "principal_investigators": new_pi,
                        "affiliated_organization": new_org,
                        "contact_email": new_email,
                        "ethics_approval_id": new_ethics,
                        "start_date": new_start.isoformat() if new_start else None,
                        "end_date": new_end.isoformat() if new_end else None
                    }
                    result = update_study(
                        study_id=study.get("study_id"),
                        updates=updates,
                        supabase=supabase
                    )
                    if result:
                        # Update session state too
                        st.session_state.active_study.update(updates)
                        st.success("Study updated successfully!")
                        st.rerun()
        else:
            st.warning("No study found in your session. Please log out and log in again.")

    # --- Patient Management ---
    with tab2:
        st.header("Patient Status Management")

        users_df = fetch_table_data("user_profiles", supabase)

        # Filter to patients in this study
        study_code = st.session_state.get("active_study", {}).get("study_code")
        if not users_df.empty and "research_study_code" in users_df.columns and study_code:
            users_df = users_df[users_df["research_study_code"] == study_code]

        if not users_df.empty:
            cols = ["id", "research_study_code", "status"] if "status" in users_df.columns else ["id", "research_study_code"]
            st.dataframe(users_df[cols], use_container_width=True)

            st.divider()
            st.subheader("Update Patient Status")

            def format_func(user_id):
                row = users_df[users_df["id"] == user_id].iloc[0]
                return f"{user_id} (Study: {row.get('research_study_code', 'N/A')})"

            user_ids = users_df["id"].tolist()
            selected_user_id = st.selectbox("Select Patient", user_ids, format_func=format_func)

            if selected_user_id:
                current_status = "active"
                if "status" in users_df.columns:
                    user_row = users_df[users_df["id"] == selected_user_id].iloc[0]
                    current_status = user_row.get("status", "active") or "active"

                status_opts = ["active", "completed", "withdrawn", "inactive"]
                new_status = st.selectbox(
                    "New Status",
                    status_opts,
                    index=status_opts.index(current_status) if current_status in status_opts else 0
                )
                if st.button("Update Status", type="primary"):
                    update_patient_status(selected_user_id, new_status, supabase)
                    st.success(f"Patient {selected_user_id} updated to '{new_status}'.")
                    st.rerun()
        else:
            st.info("No patients enrolled in your study yet.")
