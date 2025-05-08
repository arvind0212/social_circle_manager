import logging
import os
from typing import Literal, List, Dict, Any
from fastapi import FastAPI, HTTPException, Request, Depends
from pydantic import BaseModel, Field
import jwt

import database as db
from ingestion import IngesionLLMConfig, get_constraints_from_calendar_url
from logs import setup_logging

import recommender # Ensure this is imported to check its path
print(f"--- API.PY: Attempting to import recommender. Path found: {recommender.__file__} ---")

from recommender import (
    RecommenderLLMConfig,
    rank_recommendations,
    get_recommendations,
)

import dotenv

dotenv.load_dotenv()
API_TOKEN = os.environ.get("HOST_API_TOKEN")

setup_logging()
logging.info("Starting API server...")
app = FastAPI()


@app.middleware("http")
async def verify_token(request: Request, call_next):
    if request.headers.get("X-API-KEY") != API_TOKEN:
        raise HTTPException(status_code=401, detail="Unauthorized")
    return await call_next(request)


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/events")
async def get_all_events():
    """
    Get all events from the database.
    """
    logging.info("Getting all events")

    db_client = db.get_database_client()
    events = db.get_events(db_client=db_client)

    if not events:
        raise HTTPException(status_code=404, detail="No events found")

    return {"events": events}


@app.get("/users")
async def get_all_users():
    """
    Get all users from the database.
    """
    logging.info("Getting all users")

    db_client = db.get_database_client()
    users = db.get_users_in_group(group_id=1, db_client=db_client)

    if not users:
        raise HTTPException(status_code=404, detail="No users found")

    return {"users": users}


@app.get("/users={user_id}")
async def get_user(user_id: int):
    """
    Get a user from the database.
    """
    logging.info(f"Getting user {user_id}")

    db_client = db.get_database_client()
    user = db.get_user_info(user_id=user_id, db_client=db_client)

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return {"user": user}


@app.get("/groups")
async def get_all_groups():
    """
    Get all groups from the database.
    """
    logging.info("Getting all groups")

    db_client = db.get_database_client()
    groups = db.get_group_for_session(session_id=1, db_client=db_client)

    if not groups:
        raise HTTPException(status_code=404, detail="No groups found")

    return {"groups": groups}


@app.get("/groups={group_id}")
async def get_group(group_id: int):
    """
    Get all users in a group from the database.
    """
    logging.info(f"Getting users in group {group_id}")

    db_client = db.get_database_client()
    group = db.get_group(group_id=group_id, db_client=db_client)

    if not group:
        raise HTTPException(status_code=404, detail="Group not found")

    return group


@app.get("/groups={group_id}/users")
async def get_users_in_group(group_id: int):
    """
    Get all users in a group from the database.
    """
    logging.info(f"Getting users in group {group_id}")

    db_client = db.get_database_client()
    users = db.get_users_in_group(group_id=group_id, db_client=db_client)
    if not users:
        raise HTTPException(status_code=404, detail="No users found in group")

    return {"users": users}


@app.get("/sessions={session_id}")
async def get_session(session_id: int):
    """
    Get a session from the database.
    """
    logging.info(f"Getting session {session_id}")

    db_client = db.get_database_client()
    session = db.get_session(session_id=session_id, db_client=db_client)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    return {"session": session}


@app.get("/sessions={session_id}/users")
async def get_users_in_session(session_id: int):
    """
    Get all users in a session from the database.
    """
    logging.info(f"Getting users in session {session_id}")

    db_client = db.get_database_client()
    users = db.get_users_in_session(session_id=session_id, db_client=db_client)
    if not users:
        raise HTTPException(status_code=404, detail="No users found in session")

    return {"users": users}


@app.get("/sessions={session_id}/recommendations")
async def get_recommendations_for_session(session_id: int):
    """
    Get recommendations for a list of events and users.
    """
    logging.info(f"Getting recommendations for session {session_id}")

    # TODO: Authentication
    db_client = db.get_database_client()

    try:
        group = db.get_group_for_session(session_id, db_client=db_client)
        users = db.get_users_in_group(group["id"], db_client=db_client)
        events = db.get_events(db_client=db_client)
    except ValueError as e:
        return {"error": str(e)}

    llm_config = RecommenderLLMConfig()
    model = llm_config.init_model()

    try:
        recommendations = await get_recommendations(
            model=model,
            llm_config=llm_config,
            events=events,
            users=users,
        )
    except BaseException as e:
        logging.error(f"Error getting recommendations: {e}")
        return {"error": "Failed to get recommendations"}

    logging.info(f"Recommendations for session {session_id}: {recommendations}")

    aggregated_recommendations = await rank_recommendations(
        recommendations=recommendations,
    )
    return {"recommendations": aggregated_recommendations}


@app.post("/users/add")
async def add_user(
    username: str,
    first_name: str,
    last_name: str,
    email: str,
    bio: str | None = None,
    age: int | None = None,
    city: str | None = None,
    country: str | None = None,
    address: str | None = None,
):
    """
    Add a user to the database.
    """
    logging.info(f"Adding user {username}")

    db_client = db.get_database_client()
    user = db.add_user(
        username=username,
        first_name=first_name,
        last_name=last_name,
        email=email,
        bio=bio,
        age=age,
        city=city,
        country=country,
        address=address,
        db_client=db_client,
    )

    if not user:
        raise HTTPException(status_code=400, detail="Failed to add user")

    return {"user": user}


@app.post("/session/add")
async def add_session(
    group_id: int,
    started_by_user_id: int | None = None,
    start_context: str | None = None,
):
    """
    Add a session to the database.
    """
    logging.info(
        f"Adding session to group {group_id}, started by user {started_by_user_id} with context {start_context}"
    )

    db_client = db.get_database_client()
    session = db.add_session(
        group_id=group_id,
        started_by_user_id=started_by_user_id,
        start_context=start_context,
        db_client=db_client,
    )

    if not session:
        raise HTTPException(status_code=400, detail="Failed to add session")

    return {"session": session}


class UserPreference(BaseModel):
    user_id: int
    preference_type: Literal["preference", "constraint"]
    description: str
    expires_at: str | None = None
    data_source: Literal["calendar", "manual"] | None = None


@app.post("/preferences/add")
async def add_user_preferences(
    preference: UserPreference,
):
    """
    Add preferences to a user in the database.
    """
    logging.info(f"Adding preferences to user {preference.user_id}")

    db_client = db.get_database_client()
    user = db.add_preference_for_user(
        **preference.model_dump(),
        db_client=db_client,
    )

    if not user:
        raise HTTPException(status_code=400, detail="Failed to add preferences")

    return {"user": user}


class CalendarIngest(BaseModel):
    user_id: int
    calendar_url: str


@app.post("/preferences/ingest/calendar")
async def ingest_calendar(
    ingest: CalendarIngest,
):
    """
    Ingest a calendar from a URL.
    """
    logging.info(f"Ingesting calendar for user {ingest.user_id}")

    llm_config = IngesionLLMConfig()
    model = llm_config.init_model()

    constraints = await get_constraints_from_calendar_url(
        model=model,
        llm_config=llm_config,
        url=ingest.calendar_url,
    )

    db_client = db.get_database_client()
    for constraint in constraints:
        db.add_preference_for_user(
            user_id=ingest.user_id,
            preference_type="constraint",
            description=constraint,
            expires_at=None,
            data_source="calendar",
            db_client=db_client,
        )


class EventMatchingRequest(BaseModel):
    circle_id: str
    event_preferences: str | None = None
    budget: str | None = None
    availability: str | None = None


class RecommendationScoreDetail(BaseModel):
    constraint_time: float | None = None
    constraint_location: float | None = None
    constraint_other: float | None = None
    preference: float | None = None


class RecommendationResult(BaseModel):
    recommendation_id: str
    event_id: str
    event_table_origin: Literal["events", "external_events"]
    event_data: Dict[str, Any]
    score_total: float
    scores: RecommendationScoreDetail | None = None
    reasoning: str | None = None


class EventMatchingResponse(BaseModel):
    session_id: str
    recommendations: List[RecommendationResult]


async def get_requesting_user_id(request: Request) -> str:
    auth_header = request.headers.get("Authorization")
    if not auth_header:
        raise HTTPException(status_code=401, detail="Not authenticated: Missing Authorization header")

    parts = auth_header.split()
    if parts[0].lower() != "bearer" or len(parts) == 1 or len(parts) > 2:
        raise HTTPException(
            status_code=401, detail="Invalid Authorization header format. Expected 'Bearer token'"
        )
    
    token = parts[1]
    
    supabase_url = os.environ.get("SUPABASE_URL")
    if not supabase_url:
        logging.error("SUPABASE_URL not configured for JWT validation.")
        raise HTTPException(status_code=500, detail="Server configuration error for authentication.")
        
    # Extract project_ref from SUPABASE_URL (e.g., https://<project_ref>.supabase.co)
    try:
        project_ref = supabase_url.split("//")[1].split(".")[0]
        expected_issuer = f"https://{project_ref}.supabase.co/auth/v1"
    except IndexError:
        logging.error(f"Could not parse project_ref from SUPABASE_URL: {supabase_url}")
        raise HTTPException(status_code=500, detail="Server configuration error for issuer validation.")

    jwt_secret = os.environ.get("SUPABASE_JWT_SECRET")
    if not jwt_secret:
        logging.error("SUPABASE_JWT_SECRET not configured.")
        raise HTTPException(status_code=500, detail="Server configuration error for authentication.")

    try:
        payload = jwt.decode(
            token,
            jwt_secret,
            algorithms=["HS256"],
            audience="authenticated",
            issuer=expected_issuer 
        )
        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid token: Missing user ID (sub).")
        return user_id
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired.")
    except jwt.InvalidAudienceError:
        raise HTTPException(status_code=401, detail="Invalid token audience.")
    except jwt.InvalidIssuerError:
        raise HTTPException(status_code=401, detail="Invalid token issuer.")
    except jwt.PyJWTError as e:
        logging.warning(f"JWT validation error: {e}")
        raise HTTPException(status_code=401, detail=f"Invalid token: {e}")


@app.post("/event-matching/submit", response_model=EventMatchingResponse)
async def submit_event_matching(
    request_data: EventMatchingRequest,
    requesting_user_id: str = Depends(get_requesting_user_id)
):
    """
    Handles event matching requests:
    1. Creates a matching session.
    2. Fetches circle members, circle events, and external events.
    3. Calls the LLM recommender logic.
    4. Aggregates recommendations.
    5. Saves recommendations to the database.
    6. Returns the session ID and formatted recommendations.
    """
    logging.info(f"Received event matching request for circle: {request_data.circle_id} by user: {requesting_user_id}")

    session_data = db.add_event_matching_session(
        circle_id_str=request_data.circle_id,
        created_by_user_id_str=requesting_user_id,
        event_preferences_text=request_data.event_preferences,
        budget_text=request_data.budget,
        availability_text=request_data.availability
    )
    if not session_data or "id" not in session_data:
        logging.error("Failed to create event matching session in DB.")
        raise HTTPException(status_code=500, detail="Failed to initiate matching session")
    session_id_str = session_data["id"]
    logging.info(f"Created matching session: {session_id_str}")

    try:
        users_in_circle = db.get_users_in_circle(circle_id_str=request_data.circle_id)
        circle_events = db.get_circle_events(circle_id=request_data.circle_id)
        external_events = db.get_external_events()
        
        if not users_in_circle:
            logging.warning(f"No users found for circle {request_data.circle_id}. Cannot generate recommendations.")
            # Clear potentially sensitive data before returning
            # users_in_circle = [] 
            # circle_events = []
            # external_events = []
            # Consider returning empty recommendations immediately
            # return EventMatchingResponse(session_id=session_id_str, recommendations=[])
            # For now, let it proceed, but LLM might behave unexpectedly with no users.

        logging.info(f"Fetched {len(users_in_circle)} users, {len(circle_events)} circle events, {len(external_events)} external events.")

    except Exception as e:
        # ---> Add explicit exception logging here <--- 
        logging.exception(f"Error fetching data for session {session_id_str}: {e}") # Use logging.exception
        raise HTTPException(status_code=500, detail="Error fetching data for recommendations")

    all_potential_events_with_origin: List[Dict[str, Any]] = []
    for event_dict in circle_events:
        if event_dict.get('id'):
            all_potential_events_with_origin.append({"data": event_dict, "origin": "events"}) 
    for event_dict in external_events:
        if event_dict.get('id'):
             all_potential_events_with_origin.append({"data": event_dict, "origin": "external_events"})

    if not all_potential_events_with_origin:
        logging.info(f"No events found to recommend for session {session_id_str}.")
        return EventMatchingResponse(session_id=session_id_str, recommendations=[])

    formatted_users_for_llm = users_in_circle

    try:
        llm_config = RecommenderLLMConfig() 
        model = llm_config.init_model()

        logging.info(f"Calling LLM recommender for {len(all_potential_events_with_origin)} events and {len(formatted_users_for_llm)} users...")
        
        raw_recommendations = await get_recommendations(
            model=model,
            llm_config=llm_config,
            events_with_origin=all_potential_events_with_origin,
            users=formatted_users_for_llm     
        )
        logging.info(f"Received {len(raw_recommendations)} raw recommendations from LLM.")

        aggregated_recommendations = await rank_recommendations(raw_recommendations)
        logging.info(f"Aggregated into {len(aggregated_recommendations)} final recommendations.")

    except Exception as e:
        logging.exception(f"Error during LLM recommendation or aggregation for session {session_id_str}: {e}")
        raise HTTPException(status_code=500, detail=f"Error generating recommendations: {e}")

    saved_recs_for_response: List[RecommendationResult] = []
    for agg_rec in aggregated_recommendations:
        try:
            event_id = agg_rec.get('event_id')
            origin = agg_rec.get('origin')
            event_data = agg_rec.get('event_data', {})
            score_total = agg_rec.get('score_total')
            sub_scores = agg_rec.get('scores', {})
            reasoning = agg_rec.get('reasoning')

            if not all([event_id, origin, score_total is not None]):
                logging.warning(f"Skipping saving recommendation due to missing data: {agg_rec}")
                continue

            scores_detail = RecommendationScoreDetail(
                constraint_time=sub_scores.get('constraint_time'),
                constraint_location=sub_scores.get('constraint_location'),
                constraint_other=sub_scores.get('constraint_other'),
                preference=sub_scores.get('preference')
            )

            saved_db_rec = db.add_event_recommendation(
                session_id_str=session_id_str,
                event_id_str=event_id,
                event_table_origin=origin,
                score_total=float(score_total),
                scores=sub_scores,
                llm_reasoning=reasoning
            )

            if saved_db_rec and "id" in saved_db_rec:
                saved_recs_for_response.append(
                    RecommendationResult(
                        recommendation_id=saved_db_rec["id"],
                        event_id=event_id,
                        event_table_origin=origin,
                        event_data=event_data,
                        score_total=float(score_total),
                        scores=scores_detail,
                        reasoning=reasoning
                    )
                )
            else:
                logging.error(f"Failed to save recommendation for event {event_id} to DB.")

        except Exception as e:
            logging.exception(f"Error saving recommendation for event {agg_rec.get('event_id')} to DB: {e}")

    logging.info(f"Successfully processed and saved {len(saved_recs_for_response)} recommendations for session {session_id_str}.")
    
    return EventMatchingResponse(
        session_id=session_id_str,
        recommendations=saved_recs_for_response
    )
