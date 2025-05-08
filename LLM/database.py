import logging
import os
from typing import Any, Dict, List, Literal

from supabase import create_client, Client


_supabase_client: Client | None = None


def create_database_client() -> Client:
    """
    Create a Supabase client using the provided URL and key.
    """
    url = os.environ.get("SUPABASE_URL")
    if url is None:
        raise ValueError("SUPABASE_URL must be set in environment variables.")

    key = os.environ.get("SUPABASE_KEY") # Should be service_role key
    if key is None:
        raise ValueError("SUPABASE_KEY must be set in environment variables (service_role key recommended).")

    return create_client(url, key)


def get_database_client() -> Client:
    global _supabase_client

    if _supabase_client is None:
        _supabase_client = create_database_client()

    return _supabase_client


def get_circle_events(circle_id: str, db_client: Client | None = None) -> List[Dict]:
    """
    Get all events for a specific circle from the database.
    """
    logging.info(f"Getting events for circle {circle_id}")
    db_client = db_client or get_database_client()
    try:
        response = db_client.table("events").select("*").eq("circle_id", circle_id).execute()
        if response.data:
            logging.info(f"Found {len(response.data)} events for circle {circle_id}")
            return response.data
        else:
            logging.info(f"No events found for circle {circle_id}")
            return []
    except Exception as e:
        logging.error(f"Error fetching events for circle {circle_id}: {e}")
        return []

def get_external_events(db_client: Client | None = None) -> List[Dict]:
    """
    Get all external events from the database.
    """
    logging.info("Getting all external events")
    db_client = db_client or get_database_client()
    try:
        response = db_client.table("external_events").select("*").execute()
        if response.data:
            logging.info(f"Found {len(response.data)} external events")
            return response.data
        else:
            logging.info("No external events found.")
            return []
    except Exception as e:
        logging.error(f"Error fetching external events: {e}")
        return []


def get_user_profile_and_attributes(
    user_id_str: str, # Expecting UUID as string
    db_client: Client | None = None,
) -> Dict:
    """
    Get user profile information and their attributes from the database.
    """
    logging.info(f"Getting user profile and attributes for user_id {user_id_str}")
    db_client = db_client or get_database_client()
    user_data = {}

    try:
        # Get user profile
        profile_response = db_client.table("user_profiles").select("*").eq("id", user_id_str).maybe_single().execute()
        if profile_response.data:
            user_data.update(profile_response.data)
        else:
            logging.warning(f"User profile not found for user_id {user_id_str}")
            return {} # User not found, return empty

        # Get user attributes
        attributes_response = (
            db_client.table("user_attributes")
            .select("attribute_type, description, source")
            .eq("user_id", user_id_str)
            .execute()
        )
        if attributes_response.data:
            user_data["attributes"] = attributes_response.data
        else:
            user_data["attributes"] = []
        
        logging.info(f"Successfully fetched profile and attributes for user_id {user_id_str}")
        return user_data
    except Exception as e:
        logging.error(f"Error fetching profile/attributes for user_id {user_id_str}: {e}")
        return {}


def get_event_matching_session(session_id_str: str, db_client: Client | None = None) -> Dict:
    """
    Get an event matching session from the database.
    ID is UUID as string.
    """
    logging.info(f"Getting event matching session {session_id_str}")
    db_client = db_client or get_database_client()
    try:
        response = db_client.table("event_matching_sessions").select("*").eq("id", session_id_str).maybe_single().execute()
        if response.data:
            logging.info(f"Found event matching session {session_id_str}")
            return response.data
        else:
            logging.warning(f"Event matching session not found: {session_id_str}")
            return {}
    except Exception as e:
        logging.error(f"Error fetching event matching session {session_id_str}: {e}")
        return {}

def get_circle_details(circle_id_str: str, db_client: Client | None = None) -> Dict:
    """
    Get circle details from the database.
    ID is UUID as string.
    """
    logging.info(f"Getting circle details for {circle_id_str}")
    db_client = db_client or get_database_client()
    try:
        response = db_client.table("circles").select("*").eq("id", circle_id_str).maybe_single().execute()
        if response.data:
            logging.info(f"Found circle {circle_id_str}")
            return response.data
        else:
            logging.warning(f"Circle not found: {circle_id_str}")
            return {}
    except Exception as e:
        logging.error(f"Error fetching circle {circle_id_str}: {e}")
        return {}


def get_users_in_circle(circle_id_str: str, db_client: Client | None = None) -> List[Dict]:
    """
    Get all user profiles for users who are 'joined' members of a specific circle.
    circle_id_str is UUID as string.
    Returns a list of user profiles with their attributes.
    """
    logging.info(f"Getting 'joined' users in circle {circle_id_str}")
    db_client = db_client or get_database_client()
    users_data = []
    try:
        members_response = (
            db_client.table("circle_members")
            .select("user_id")
            .eq("circle_id", circle_id_str)
            .eq("status", "joined") # Assuming 'joined' status means active member
            .execute()
        )

        if not members_response.data:
            logging.info(f"No 'joined' members found for circle {circle_id_str}")
            return []

        for member in members_response.data:
            user_id = member.get("user_id")
            if user_id:
                user_profile = get_user_profile_and_attributes(user_id, db_client=db_client)
                if user_profile: # Only add if profile was found
                    users_data.append(user_profile)
        
        logging.info(f"Found {len(users_data)} 'joined' users in circle {circle_id_str}")
        return users_data
    except Exception as e:
        logging.error(f"Error fetching users in circle {circle_id_str}: {e}")
        return []

def get_circle_for_session(session_id_str: str, db_client: Client | None = None) -> Dict:
    """
    Get the circle details for a given event matching session.
    session_id_str is UUID as string.
    """
    logging.info(f"Getting circle for event matching session {session_id_str}")
    db_client = db_client or get_database_client()
    try:
        session = get_event_matching_session(session_id_str, db_client=db_client)
        if not session or "circle_id" not in session:
            logging.warning(f"Session {session_id_str} not found or missing circle_id.")
            return {}
        
        circle_id = session["circle_id"]
        return get_circle_details(circle_id, db_client=db_client)
    except Exception as e:
        logging.error(f"Error fetching circle for session {session_id_str}: {e}")
        return {}


def get_users_for_session(session_id_str: str, db_client: Client | None = None) -> List[Dict]:
    """
    Get all 'joined' users in the circle associated with an event matching session.
    session_id_str is UUID as string.
    """
    logging.info(f"Getting users for event matching session {session_id_str}")
    db_client = db_client or get_database_client()
    try:
        circle = get_circle_for_session(session_id_str, db_client=db_client)
        if not circle or "id" not in circle:
            logging.warning(f"Circle not found for session {session_id_str}.")
            return []
        
        return get_users_in_circle(circle["id"], db_client=db_client)
    except Exception as e:
        logging.error(f"Error fetching users for session {session_id_str}: {e}")
        return []

# def add_user(...) - Commented out as user creation is typically handled by Supabase Auth and triggers.
# If you need to UPDATE user_profiles, a separate function would be needed.

def add_event_matching_session(
    circle_id_str: str,
    created_by_user_id_str: str,
    event_preferences_text: str | None = None,
    budget_text: str | None = None,
    availability_text: str | None = None,
    db_client: Client | None = None,
) -> Dict:
    """
    Add an event matching session to the database. IDs are UUIDs as strings.
    Returns the created session data or an empty dict on failure.
    """
    logging.info(f"Adding event matching session for circle {circle_id_str} by user {created_by_user_id_str}")
    db_client = db_client or get_database_client()
    
    session_data = {
        "circle_id": circle_id_str,
        "created_by_user_id": created_by_user_id_str,
        "event_preferences_text": event_preferences_text,
        "budget_text": budget_text,
        "availability_text": availability_text,
    }
    try:
        response = db_client.table("event_matching_sessions").insert(session_data).execute()
        if response.data:
            logging.info(f"Successfully added event matching session: {response.data[0]['id']}")
            return response.data[0]
        else:
            logging.error(f"Failed to add event matching session, response: {response}")
            return {}
    except Exception as e:
        logging.error(f"Exception adding event matching session: {e}")
        return {}

def add_user_attribute(
    user_id_str: str,
    attribute_type: Literal["preference", "constraint"],
    description: str,
    source: Literal["manual", "calendar_ingestion", "llm_generated"] | None = None,
    db_client: Client | None = None,
) -> Dict:
    """
    Add a user attribute (preference or constraint) to the database.
    user_id_str is UUID as string.
    Returns the created attribute data or an empty dict on failure.
    """
    logging.info(f"Adding attribute for user {user_id_str}: type={attribute_type}, source={source}")
    db_client = db_client or get_database_client()

    attribute_data = {
        "user_id": user_id_str,
        "attribute_type": attribute_type,
        "description": description,
        "source": source,
    }
    try:
        response = db_client.table("user_attributes").insert(attribute_data).execute()
        if response.data:
            logging.info(f"Successfully added user attribute: {response.data[0]['id']}")
            return response.data[0]
        else:
            logging.error(f"Failed to add user attribute, response: {response}")
            return {}
    except Exception as e:
        logging.error(f"Exception adding user attribute for user {user_id_str}: {e}")
        return {}

def add_event_recommendation(
    session_id_str: str,
    event_id_str: str, # This is the ID of the event (either circle_event or external_event)
    event_table_origin: Literal["events", "external_events"], # To know which FK to populate
    score_total: float,
    scores: Dict[str, float | None], # e.g., {"constraint_time": 9.0, "preference": 7.5}
    llm_reasoning: str | None = None,
    db_client: Client | None = None,
) -> Dict:
    """
    Add an event recommendation to the database.
    session_id_str and event_id_str are UUIDs.
    Returns the created recommendation data or an empty dict on failure.
    """
    logging.info(f"Adding recommendation for session {session_id_str}, event {event_id_str} from {event_table_origin}")
    db_client = db_client or get_database_client()

    recommendation_data = {
        "session_id": session_id_str,
        "score_total": score_total,
        "score_constraint_time": scores.get("constraint_time"),
        "score_constraint_location": scores.get("constraint_location"),
        "score_constraint_other": scores.get("constraint_other"),
        "score_preference": scores.get("preference"),
        "llm_reasoning": llm_reasoning,
    }
    if event_table_origin == "events":
        recommendation_data["circle_event_id"] = event_id_str
        recommendation_data["external_event_id"] = None
    elif event_table_origin == "external_events":
        recommendation_data["external_event_id"] = event_id_str
        recommendation_data["circle_event_id"] = None
    else:
        logging.error(f"Invalid event_table_origin: {event_table_origin}")
        return {}
        
    try:
        response = db_client.table("event_matching_recommendations").insert(recommendation_data).execute()
        if response.data:
            logging.info(f"Successfully added event recommendation: {response.data[0]['id']}")
            return response.data[0]
        else:
            logging.error(f"Failed to add event recommendation, response: {response}")
            return {}
    except Exception as e:
        logging.error(f"Exception adding event recommendation for session {session_id_str}: {e}")
        return {}

# Example usage (for testing, can be removed)
if __name__ == '__main__':
    # Attempt to load .env file from parent directory (social_circle_manager/.env)
    try:
        from dotenv import load_dotenv
        import os
        # Construct the path to the .env file, assuming it's in social_circle_manager/
        # database.py is in social_circle_manager/LLM/
        dotenv_path = os.path.join(os.path.dirname(__file__), '..', '.env')
        if os.path.exists(dotenv_path):
            print(f"Loading .env file from: {os.path.abspath(dotenv_path)}")
            load_dotenv(dotenv_path=dotenv_path)
        else:
            print(f".env file not found at expected location: {os.path.abspath(dotenv_path)}")
            print("Please ensure .env file exists in social_circle_manager/ directory.")
    except ImportError:
        print("python-dotenv library not found. Please install it (pip install python-dotenv) to load .env file for testing.")
    except Exception as e:
        print(f"Error loading .env file: {e}")

    # Configure logging for testing
    logging.basicConfig(level=logging.INFO)
    
    # --- IMPORTANT ---
    # For this example to run, you MUST have SUPABASE_URL and SUPABASE_KEY
    # set as environment variables, pointing to your "Circle" project.
    # The SUPABASE_KEY should be your service_role key.
    # You also need to have run the SQL to create the tables.

    print("Testing database functions...")
    client = get_database_client()
    if not client:
        print("Failed to create Supabase client. Check environment variables.")
    else:
        print("Supabase client created.")

        # --- Test Data (replace with actual IDs from your DB for full testing) ---
        # Replace with an actual user_id (UUID string) from your user_profiles table
        test_user_id = "87c01830-ca16-4e03-b945-8aa807258299" # Diana's ID
        # Replace with an actual circle_id (UUID string) Diana belongs to
        test_circle_id = "ab254c7a-449e-4726-8599-c5d3ad5faa08" 
        
        # 1. Add a user attribute for Diana
        # print("\n--- Testing add_user_attribute ---")
        # new_attribute = add_user_attribute(
        #     user_id_str=test_user_id,
        #     attribute_type="preference",
        #     description="Enjoys sunny afternoon picnics with friends.",
        #     source="manual",
        #     db_client=client
        # )
        # print(f"Added attribute: {new_attribute}")

        # 2. Get Diana's profile and attributes
        print("\n--- Testing get_user_profile_and_attributes ---")
        diana_profile = get_user_profile_and_attributes(test_user_id, db_client=client)
        if diana_profile:
            print(f"Diana's Profile & Attributes: {diana_profile}")
            if "attributes" in diana_profile:
                 print(f"Number of attributes: {len(diana_profile['attributes'])}")
        else:
            print(f"Could not fetch profile for {test_user_id}")

        # 3. Get circle details
        print("\n--- Testing get_circle_details ---")
        circle_info = get_circle_details(test_circle_id, db_client=client)
        print(f"Circle Details ({test_circle_id}): {circle_info}")

        # 4. Get users in that circle
        print("\n--- Testing get_users_in_circle ---")
        users_in_circle = get_users_in_circle(test_circle_id, db_client=client)
        print(f"Users in Circle ({test_circle_id}): {len(users_in_circle)} users")
        # for user_prof in users_in_circle:
        #     print(f"  - {user_prof.get('full_name', user_prof.get('id'))}")

        # 5. Add an event matching session
        print("\n--- Testing add_event_matching_session ---")
        session_payload = {
            "circle_id_str": test_circle_id,
            "created_by_user_id_str": test_user_id,
            "event_preferences_text": "Something chill for Friday night, maybe board games or a quiet bar?",
            "budget_text": "Under $30",
            "availability_text": "Friday evening after 7 PM"
        }
        new_session = add_event_matching_session(**session_payload, db_client=client)
        print(f"New Session: {new_session}")
        
        test_session_id = None
        if new_session and "id" in new_session:
            test_session_id = new_session["id"]
            print(f"Test session ID: {test_session_id}")
            
            # 6. Get that session
            print("\n--- Testing get_event_matching_session ---")
            fetched_session = get_event_matching_session(test_session_id, db_client=client)
            print(f"Fetched Session ({test_session_id}): {fetched_session}")

            # 7. Get users for that session
            print("\n--- Testing get_users_for_session ---")
            users_for_session = get_users_for_session(test_session_id, db_client=client)
            print(f"Users for Session ({test_session_id}): {len(users_for_session)} users")

        # 8. Get circle-specific events (if any for that circle)
        print("\n--- Testing get_circle_events ---")
        circle_events = get_circle_events(test_circle_id, db_client=client)
        print(f"Events for Circle ({test_circle_id}): {len(circle_events)} events")
        # if circle_events:
        #     print(f"First circle event: {circle_events[0]}")
        
        # 9. Get external events
        print("\n--- Testing get_external_events ---")
        ext_events = get_external_events(db_client=client)
        print(f"External Events: {len(ext_events)} events")
        
        test_external_event_id = None
        if ext_events:
            # print(f"First external event: {ext_events[0]}")
            test_external_event_id = ext_events[0].get("id") # Pick first one for recommendation test
            print(f"Test external event ID for recommendation: {test_external_event_id}")

        # 10. Add an event recommendation (if a session and an external event exist)
        if test_session_id and test_external_event_id:
            print("\n--- Testing add_event_recommendation ---")
            rec_scores = {
                "constraint_time": 8.0, 
                "constraint_location": 7.0,
                "constraint_other": 9.0,
                "preference": 8.5
            }
            new_rec = add_event_recommendation(
                session_id_str=test_session_id,
                event_id_str=test_external_event_id,
                event_table_origin="external_events",
                score_total=8.1,
                scores=rec_scores,
                llm_reasoning="Looks like a good fit based on preferences and availability!",
                db_client=client
            )
            print(f"New Recommendation: {new_rec}")
        else:
            print("\nSkipping add_event_recommendation test: missing session_id or external_event_id.")

        print("\n--- Testing complete ---")
