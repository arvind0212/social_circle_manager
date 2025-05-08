print("--- EXECUTING LLM/recommender.py ---")
print(f"--- Location of this recommender.py: {__file__} ---")

import asyncio
from typing import Annotated, NamedTuple, TypedDict, List, Dict, Any, Literal
from datetime import datetime
#from langchain_anthropic import ChatAnthropic
from langchain_core.language_models import BaseChatModel
from pydantic import BaseModel
from pydantic import AfterValidator

from database import get_database_client
from llm import BaseLLMConfig, pack_examples


SYSTEM_PROMPT = """
You are an AI assistant specialized in personalized event evaluation.

Your task is to assess a single event for a single user, based on their preferences and constraints.

You must evaluate the event across four key metrics:
- constraint_time
- constraint_location
- constraint_other
- preference

For each metric, return:
- A brief explanation of your reasoning (1–3 sentences)
- A numerical score from 1 to 10

### Scoring Rules:
- 10 = perfect match
- 5 = insufficient information to decide
- 1 = direct conflict
- Use 5 when data is missing or ambiguous (e.g., no location or constraints)
"""


# Few shot prompting
PROMPT_EXAMPLES = [
    {
        "input": {
            "event": {
                "title": "Metallica Concert",
                "location": "Friends Arena",
                "date": "Sat 12-Apr-2025",
                "time": "16:00",
            },
            "user": {
                "name": "Anna W",
                "age": 33,
                "gender": "female",
                "preferences": [
                    {
                        "preference_type": "preference",
                        "description": "loves rock",
                        "data_source": "manual",
                    },
                    {
                        "preference_type": "constraint",
                        "description": "Works on weekdays 8-17.",
                        "data_source": "calendar",
                    },
                ],
            },
        },
        "expected_output": {
            "constraint_time": {
                "reasoning": "The event is on a Saturday, which is outside of Anna's work hours. Therefore, it is a perfect match.",
                "score": 10,
            },
            "constraint_location": {
                "reasoning": "The concert is in Friends Arena, which is not specified as a preferred location.",
                "score": 5,
            },
            "constraint_other": {
                "reasoning": "There are no other constraints mentioned that would affect the event.",
                "score": 5,
            },
            "preference": {
                "reasoning": "Anna loves rock music, and Metallica is a rock band. Therefore, this event aligns perfectly with her preferences.",
                "score": 10,
            },
        },
    },
    {
        "input": {
            "event": {
                "title": "Phantom of the Opera",
                "location": "Royal Opera House (Stockholm, Sweden)",
                "date": "Thu 15-Apr-2025",
                "time": "19:00",
            },
            "user": {
                "name": "James B",
                "age": 45,
                "gender": "male",
                "address": "Stockholm, Sweden",
                "preferences": [
                    {
                        "preference_type": "preference",
                        "description": "Likes pop and modern music.",
                        "data_source": "manual",
                    },
                    {
                        "preference_type": "constraint",
                        "description": "Works on weekdays 8-17.",
                        "data_source": "calendar",
                    },
                ],
            },
        },
        "expected_output": {
            "constraint_time": {
                "reasoning": "The event is on a Thursday at 19:00, which is outside of James's work hours. It could be hard to make it in a short notice.",
                "score": 10,
            },
            "constraint_location": {
                "reasoning": "The concert is in Royal Opera House, which is in the same city as James.",
                "score": 8,
            },
            "constraint_other": {
                "reasoning": "There are no other constraints mentioned that would affect the event.",
                "score": 5,
            },
            "preference": {
                "reasoning": "James likes pop and modern music, but Phantom of the Opera is a classical musical. Given his taste in music, this event may not be a perfect match, but not enough information is given.",
                "score": 3,
            },
        },
    },
]


def is_valid_score(score: int) -> bool:
    """Check if the score is between 1 and 10."""
    return 1 <= score <= 10


class RecommendationScoring(BaseModel):
    reasoning: str
    score: int


class RecommendationScoringFormatter(BaseModel):
    """Always use this tool to format the scoring output.

    This is a Pydantic model that defines the structure of the scoring output.
    Always use this model to ensure the output is consistent and valid.
    The model contains four fields:
    - constraint_time: RecommendationScoring
    - constraint_location: RecommendationScoring
    - constraint_other: RecommendationScoring
    - preference: RecommendationScoring

    Each field is an instance of the RecommendationScoring model, which contains
    the reasoning and score for that specific metric.

    Reasoning is a string that explains the score assigned to the event.
    Reasoning should be concise and clear, providing context for the score.

    Score is an integer between 1 and 10, where:
    - 10 = perfect match
    - 5 = insufficient information to decide
    - 1 = direct conflict
    - Use 5 when data is missing or ambiguous (e.g., no location or constraints)

    """

    constraint_time: RecommendationScoring
    constraint_location: RecommendationScoring
    constraint_other: RecommendationScoring
    preference: RecommendationScoring

    @property
    def weighted_score(self) -> float:
        """Get the weighted score for the recommendation."""
        return (
            self.constraint_time.score
            + self.constraint_location.score
            + self.constraint_other.score
            + self.preference.score
        ) / 4


_recommender_llm_model: BaseChatModel | None = None


class RecommenderLLMConfig(BaseLLMConfig):
    """Configuration for the recommender chat model."""

    system_prompt: str = SYSTEM_PROMPT
    examples: list[dict[str, dict]] = PROMPT_EXAMPLES

    def init_model(self) -> BaseChatModel:
        """Get the model from the configuration."""
        global _recommender_llm_model

        if _recommender_llm_model:
            return _recommender_llm_model

        _recommender_llm_model = super().init_model()
        return _recommender_llm_model


async def get_recommendation_for_user_for_event(
    model: BaseChatModel,
    event_info: dict,
    user_info: dict,
    llm_config: RecommenderLLMConfig,
) -> RecommendationScoringFormatter:
    """Get the recommendation for the event and user."""
    # Prepare the input
    input_data = {
        "event": event_info,
        "user": user_info,
    }

    # Prepare the examples
    examples = pack_examples(llm_config.examples)

    # Prepare the messages
    messages = [
        {"role": "system", "content": llm_config.system_prompt},
        *examples,
        {"role": "user", "content": str(input_data)},
    ]

    structured_model = model.bind_tools([RecommendationScoringFormatter])

    # Get the response from the model
    response = await structured_model.ainvoke(
        input=messages,
    )

    if not hasattr(response, "tool_calls") or not response.tool_calls:  # type: ignore
        raise ValueError("No tool calls found in the response.")

    formatted_response = response.tool_calls[0]["args"]  # type: ignore

    # Parse the response
    return RecommendationScoringFormatter(**formatted_response)  # type: ignore


def format_event_info(event: dict) -> dict:
    """
    Format event information for the LLM.
    """
    event_copy = {**event}

    if "id" in event_copy:
        event_copy.pop("id")
    if "created_at" in event_copy:
        event_copy.pop("created_at")
    if "updated_at" in event_copy: 
        event_copy.pop("updated_at")
    if "circle_id" in event_copy: 
        event_copy.pop("circle_id")
    if "created_by_user_id" in event_copy:
        event_copy.pop("created_by_user_id")
    if "event_datetime" in event_copy:
        event_copy.pop("event_datetime")

    start_time_str = event_copy.pop("start_time", None) 
    end_time_str = event_copy.pop("end_time", None)

    if start_time_str:
        try:
            parsed_dt = None
            if isinstance(start_time_str, str):
                clean_start_time_str = start_time_str.split('.')[0].replace("Z", "+00:00")
                parsed_dt = datetime.fromisoformat(clean_start_time_str)
            elif isinstance(start_time_str, datetime):
                parsed_dt = start_time_str
            
            if parsed_dt:
                event_copy["date"] = parsed_dt.strftime("%a %d-%b-%Y")
                event_copy["time"] = parsed_dt.strftime("%H:%M")

        except ValueError as e_parse:
            print(f"Warning: Could not parse start_time '{start_time_str}': {e_parse}. Passing raw value if exists.")
            if isinstance(start_time_str, str):
                 event_copy["raw_start_time"] = start_time_str

    if "info" in event_copy:
        event_copy.update(event_copy.pop("info"))

    if "location_text" in event_copy and "location" not in event_copy:
        event_copy["location"] = event_copy.pop("location_text")
    
    return event_copy


def format_user_info(user: dict) -> dict:
    """
    Format user information for the LLM.
    """
    user = {**user}

    if "id" in user:
        user.pop("id")

    if "created_at" in user:
        user.pop("created_at")

    # Rename "attributes" to "preferences" for LLM compatibility
    if "attributes" in user:
        user["preferences"] = user.pop("attributes")

    return user


class UserEventRecommendation(TypedDict):
    """
    Recommendation outputs for the LLM.
    """

    event: Dict[str, Any]
    origin: Literal["events", "external_events"]
    user: Dict[str, Any]
    task: RecommendationScoringFormatter


async def get_recommendations(
    model: BaseChatModel,
    llm_config: RecommenderLLMConfig,
    events_with_origin: List[Dict[str, Any]],
    users: List[Dict[str, Any]],
) -> List[UserEventRecommendation]:
    """
    Get recommendations for a list of events and users.
    `events_with_origin` is expected to be a list of dicts, 
    where each dict has a 'data' key for the event object 
    and an 'origin' key for the source table.
    """
    tasks = []
    inputs = []

    for event_item in events_with_origin:
        original_event_data = event_item["data"]
        event_origin = event_item["origin"]
        
        event_info_for_llm = format_event_info(original_event_data)
        
        for user in users:
            user_info_for_llm = format_user_info(user)
            task = get_recommendation_for_user_for_event(
                model=model,
                event_info=event_info_for_llm,
                user_info=user_info_for_llm,
                llm_config=llm_config,
            )
            tasks.append(task)
            inputs.append(
                (
                    original_event_data,
                    event_origin,
                    user,
                )
            )

    recommendation_results = await asyncio.gather(*tasks)
    
    output_recommendations: List[UserEventRecommendation] = []
    for (original_event, origin, user), recommendation_task_result in zip(inputs, recommendation_results):
        output_recommendations.append(
            UserEventRecommendation(
                event=original_event,
                origin=origin,
                user=user,
                task=recommendation_task_result,
            )
        )
    return output_recommendations


async def rank_recommendations(
    recommendations: List[UserEventRecommendation],
) -> List[Dict[str, Any]]:
    """
    Aggregate the recommendations for all users and events.
    Returns a list of unique events, ranked by score, with aggregated details.
    """
    event_aggregation: Dict[str, Dict[str, Any]] = {}

    for recommendation in recommendations:
        original_event = recommendation["event"]
        event_id = original_event.get("id")
        if not event_id:
            continue

        task_scores = recommendation["task"]
        user_id = recommendation["user"].get("id", "UnknownUser")

        if event_id not in event_aggregation:
            event_aggregation[event_id] = {
                "event_data": original_event,
                "origin": recommendation["origin"],
                "user_recommendations": [],
                "total_score": 0.0,
                "sub_scores_sum": {
                    "constraint_time": 0.0,
                    "constraint_location": 0.0,
                    "constraint_other": 0.0,
                    "preference": 0.0,
                },
                "sub_scores_count": {
                    "constraint_time": 0,
                    "constraint_location": 0,
                    "constraint_other": 0,
                    "preference": 0,
                },
                "all_reasonings": []
            }
        
        current_agg = event_aggregation[event_id]
        current_agg["user_recommendations"].append(
            {
                "user_id": user_id,
                "scores": task_scores.model_dump()
            }
        )
        current_agg["total_score"] += task_scores.preference.score

        for field in ["constraint_time", "constraint_location", "constraint_other", "preference"]:
            score_object = getattr(task_scores, field, None)
            if score_object and hasattr(score_object, 'score'):
                score_value = score_object.score
                current_agg["sub_scores_sum"][field] += score_value
                current_agg["sub_scores_count"][field] += 1
        
        current_agg["all_reasonings"].append(f"User {user_id}: Pref score {task_scores.preference.score} - {task_scores.preference.reasoning}")

    final_ranked_list = []
    for event_id_key, agg_data in event_aggregation.items():
        num_recommendations = len(agg_data["user_recommendations"])
        if num_recommendations == 0: continue

        aggregated_sub_scores = {}
        for field, total_val in agg_data["sub_scores_sum"].items():
            count = agg_data["sub_scores_count"][field]
            aggregated_sub_scores[field] = round(total_val / count, 2) if count > 0 else 0.0
        
        reasoning_summary = "; ".join(agg_data["all_reasonings"][:2]) + ("..." if len(agg_data["all_reasonings"]) > 2 else "")

        response_item = {
            "recommendation_id": event_id_key,
            "event_id": event_id_key, 
            "event_data": agg_data["event_data"],
            "origin": agg_data["origin"],
            "score_total": round(agg_data["total_score"] / num_recommendations, 2),
            "scores": aggregated_sub_scores,
            "reasoning": reasoning_summary,
            #test 
        }
        final_ranked_list.append(response_item)

    final_ranked_list.sort(key=lambda x: x["score_total"], reverse=True)
    return final_ranked_list
