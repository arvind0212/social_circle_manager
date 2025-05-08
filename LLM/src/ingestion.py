import asyncio
from datetime import datetime
from http.client import HTTPException
from pathlib import Path
import tempfile
from typing import Any
# from langchain_anthropic import ChatAnthropic # Removed/Commented
from langchain_core.language_models import BaseChatModel
from pydantic import BaseModel
import pytz
# import requests # Unused, so removing
import aiohttp

from .connection import get_client_session # Relative import
from .llm import BaseLLMConfig, pack_examples # Relative import

from icalendar import Calendar, Component
# ... existing code ... 