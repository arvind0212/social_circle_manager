import asyncio
from datetime import datetime
from http.client import HTTPException
from pathlib import Path
import tempfile
from typing import Any
from langchain_core.language_models import BaseChatModel
from pydantic import BaseModel
import pytz
import requests
import aiohttp

from connection import get_client_session
from llm import BaseLLMConfig, pack_examples

from icalendar import Calendar, Component


PROMPT_EXAMPLES = [
    {
        "input": {
            "summary": "Meeting with Bob",
            "description": "Discuss project updates",
            "start": "2023-10-01T10:00:00+00:00",
            "end": "2023-10-01T11:00:00+00:00",
            "all_day": False,
            "timezone": "UTC",
            "rrule": None,
            "rdate": [],
            "exdate": [],
            "uid": "12345",
            "sequence": 1,
            "location": "",
        },
        "expected_output": "Meeting with Bob to discuss project updates on October 1, 2023, from 10:00 AM to 11:00 AM UTC.",
    },
    {
        "input": {
            "summary": "Hiking trip to the mountains",
            "description": "This is an all-day event.",
            "start": "2023-10-02",
            "end": "2023-10-03",
            "all_day": True,
            "timezone": None,
            "rrule": None,
            "rdate": [],
            "exdate": [],
            "uid": "67890",
            "sequence": 1,
            "location": "",
        },
        "expected_output": "All-day hiking trip to the mountains on October 2, 2023, to October 3, 2023.",
    },
    {
        "input": {
            "summary": "work",
            "description": "Working",
            "start": "2025-05-05T07:00:00+02:00",
            "end": "2025-05-05T15:00:00+02:00",
            "all_day": False,
            "timezone": "Europe/Berlin",
            "rrule": "FREQ=WEEKLY;WKST=MO;UNTIL=2025-11-21 22:59:59+00:00;BYDAY=MO,TU,WE,TH,FR",
            "rdate": [],
            "exdate": [],
            "uid": "0ats8edh1hg2s1tj762tps41u1@google.com",
            "sequence": 1,
            "location": "Ericsson HQ, Torshamnsgatan 21, 164 40 Kista, Sweden",
        },
        "expected_output": "Work at Ericsson HQ, Torshamnsgatan 21, 164 40 Kista, Sweden from May 5, 2025, 7:00 AM to 3:00 PM CEST. This is a recurring event every weekday until November 21, 2025.",
    },
]

SYSTEM_PROMPT = f"""
You are an AI assistant specialized in personalized calendar management.

Particularly, you are responsible for converting a parsed calender event into a human-readable format.
The calendar event is given to you in an intermediary format, which is a dictionary containing the following fields:
- summary: The title of the event.
- description: A detailed description of the event.
- start: The start time of the event in ISO 8601 format.
- end: The end time of the event in ISO 8601 format.
- all_day: A boolean indicating if the event is an all-day event.
- timezone: The timezone of the event.
- rrule: The recurrence rule of the event, if applicable.
- rdate: A list of recurrence dates, if applicable.
- exdate: A list of exception dates, if applicable.
- uid: The unique identifier of the event.
- sequence: The sequence number of the event.

Your task is to convert this parsed calendar event into a human-readable format.
Particularly, it should be a short summary of the event, including the title, start and end times, and any other relevant information.
Keep it concise and clear, 1-3 sentences.

It is important to get the start and end times right, as well as the timezone.
"""


_ingestion_llm_model: BaseChatModel | None = None


class IngesionLLMConfig(BaseLLMConfig):
    system_prompt: str = SYSTEM_PROMPT
    examples: list[dict] = PROMPT_EXAMPLES

    def init_model(self) -> BaseChatModel:
        global _ingestion_llm_model

        if _ingestion_llm_model:
            return _ingestion_llm_model

        _ingestion_llm_model = super().init_model()
        return _ingestion_llm_model


async def download_calendar(
    url: str, dest_path: Path, session: aiohttp.ClientSession | None = None
) -> None:
    """
    Download a directory from a given URL.
    """
    dest_path.parent.mkdir(parents=True, exist_ok=True)

    session = session or get_client_session()
    async with session.head(url) as response:
        print(response.headers)

    async with session.get(url) as response:
        if response.status != 200:
            raise HTTPException(f"Failed to download file: {response.status}")

        with open(dest_path, "wb") as f:
            f.write(await response.read())


def load_calendar(path: Path) -> Calendar:
    with open(path, "rb") as f:
        return Calendar.from_ical(f.read())  # type: ignore[no-untyped-call]


async def load_calendar_from_url(url: str) -> Calendar:
    """
    Load a calendar from a URL.
    """
    with tempfile.TemporaryDirectory() as tmpdirname:
        dest_path = Path(tmpdirname) / "calendar.ics"
        await download_calendar(url, dest_path)
        return load_calendar(dest_path)


def get_timezone(calendar: Calendar) -> Any | None:
    """
    Get the timezone from the calendar.
    """
    for component in calendar.timezones:
        return component.to_tz()  # type: ignore

    return None


def parse_event(component: Component, calendar_tz=None) -> dict[str, Any]:
    def parse_dt(dt):
        if isinstance(dt, datetime):
            if dt.tzinfo is None:
                return (
                    calendar_tz.localize(dt)
                    if calendar_tz
                    else dt.replace(tzinfo=pytz.UTC)
                )
        return dt  # could be a date (all-day event)

    dtstart = component.get("DTSTART").dt
    dtend = component.get("DTEND").dt

    start = parse_dt(dtstart)
    end = parse_dt(dtend)

    all_day = not isinstance(dtstart, datetime)
    tzinfo = str(start.tzinfo) if isinstance(start, datetime) else None

    # Parse recurrence rule
    rrule = component.get("RRULE")
    rrule_str = None
    if rrule:
        rrule_str = ";".join(f"{k}={','.join(map(str, v))}" for k, v in rrule.items())

    # Parse RDATEs
    rdates = []
    if component.get("RDATE"):
        for r in component.get("RDATE").dts:
            rdates.append(parse_dt(r.dt))

    # Parse EXDATEs
    exdates = []
    if component.get("EXDATE"):
        for ex in component.get("EXDATE").dts:
            exdates.append(parse_dt(ex.dt))

    location = str(component.get("LOCATION", ""))

    return {
        "summary": str(component.get("SUMMARY", "")),
        "description": str(component.get("DESCRIPTION", "")),
        "start": start.isoformat(),
        "end": end.isoformat(),
        "all_day": all_day,
        "timezone": tzinfo,
        "rrule": rrule_str,
        "rdate": [dt.isoformat() for dt in rdates],
        "exdate": [dt.isoformat() for dt in exdates],
        "uid": str(component.get("UID", "")),
        "sequence": int(component.get("SEQUENCE", 0)),
        "location": location,
    }


async def get_constraint_from_event(
    model: BaseChatModel,
    llm_config: IngesionLLMConfig,
    event: dict[str, Any],
) -> str:
    """
    Extract constraints from a calendar event.
    """
    messages = [
        {
            "role": "system",
            "content": llm_config.system_prompt,
        },
        *pack_examples(llm_config.examples),
        {
            "role": "user",
            "content": str(event),
        },
    ]

    response = await model.ainvoke(
        input=messages,
    )
    if not response:
        raise HTTPException("Failed to get response from LLM")

    if not isinstance(response.content, str):
        raise HTTPException(f"Response {response.content} is not a string")

    return response.content


async def get_constraints_from_calendar(
    model: BaseChatModel,
    llm_config: IngesionLLMConfig,
    calendar: Calendar,
) -> list[str]:
    """
    Extract events from a calendar.
    """
    calendar_tz = get_timezone(calendar)
    events = [parse_event(event, calendar_tz) for event in calendar.events]
    tasks = [get_constraint_from_event(model, llm_config, event) for event in events]

    constraints = await asyncio.gather(*tasks)
    return constraints


async def get_constraints_from_calendar_url(
    model: BaseChatModel,
    llm_config: IngesionLLMConfig,
    url: str,
) -> list[str]:
    """
    Get constraints from a calendar URL.
    """
    calendar = await load_calendar_from_url(url)
    return await get_constraints_from_calendar(model, llm_config, calendar)
