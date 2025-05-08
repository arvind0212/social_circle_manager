import requests
import json # For printing the response nicely
import os # To load .env if needed, though JWT and HOST_API_KEY are hardcoded below for this example

# --- CONFIGURATION (Replace with your actual values IF DIFFERENT) ---
BASE_URL = "http://127.0.0.1:8000" # Assuming FastAPI runs locally on port 8000
EVENT_MATCHING_ENDPOINT = f"{BASE_URL}/event-matching/submit"

# 1. Your HOST_API_TOKEN (from your .env file)
#    Replace "YOUR_ACTUAL_HOST_API_TOKEN" with the real token from your .env
HOST_API_KEY = "YOUR_ACTUAL_HOST_API_TOKEN"

# 2. A valid Supabase User JWT (obtain this by logging in a test user)
#    Replace "YOUR_VALID_SUPABASE_USER_JWT" with the real JWT
SUPABASE_USER_JWT = "YOUR_VALID_SUPABASE_USER_JWT"

# 3. Test Data
#    Use an actual circle_id from your database that has members and associated data.
TEST_CIRCLE_ID = "ab254c7a-449e-4726-8599-c5d3ad5faa08" # Example from database.py tests. VERIFY THIS EXISTS & HAS DATA.

request_payload = {
    "circle_id": TEST_CIRCLE_ID,
    "event_preferences": "Looking for something fun and active outdoors this weekend.",
    "budget": "Under $50 per person",
    "availability": "Saturday afternoon, perhaps Sunday morning too"
}

headers = {
    "X-API-KEY": HOST_API_KEY,
    "Authorization": f"Bearer {SUPABASE_USER_JWT}",
    "Content-Type": "application/json"
}

# --- MAKE THE REQUEST ---
try:
    print(f"Sending POST request to: {EVENT_MATCHING_ENDPOINT}")
    print(f"Payload: {json.dumps(request_payload, indent=2)}")
    # For security, avoid printing full headers if JWT is sensitive in shared logs.
    # print(f"Headers: {headers}") 

    response = requests.post(EVENT_MATCHING_ENDPOINT, json=request_payload, headers=headers, timeout=300) # Added timeout

    print(f"\n--- RESPONSE ---")
    print(f"Status Code: {response.status_code}")
    try:
        response_json = response.json()
        print(f"Response Body:\n{json.dumps(response_json, indent=2)}")
    except json.JSONDecodeError:
        print(f"Response Body (Not JSON):\n{response.text}")

except requests.exceptions.Timeout:
    print(f"\nRequest timed out after 300 seconds. The LLM processing might be taking too long.")
except requests.exceptions.ConnectionError as e:
    print(f"\nConnection Error: Could not connect to the server at {BASE_URL}.")
    print("Please ensure your FastAPI application (api.py) is running.")
    print(f"Details: {e}")
except Exception as e:
    print(f"\nAn unexpected error occurred: {e}")
