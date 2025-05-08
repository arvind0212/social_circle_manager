import os # Added for API key access
from langchain.chat_models.base import BaseChatModel
# from langchain_anthropic import ChatAnthropic # Replaced with Gemini
from langchain_google_genai import ChatGoogleGenerativeAI # Added for Gemini
from pydantic import BaseModel


class BaseLLMConfig(BaseModel):
    model_name: str = "gemini-1.5-flash-latest" # Changed to Gemini model
    temperature: float = 0.2
    max_tokens: int = 1024 # Adjusted for potentially larger Gemini output, maps to max_output_tokens

    def init_model(self) -> BaseChatModel:
        # Ensure GEMINI_API_KEY is loaded from .env
        api_key = os.environ.get("GEMINI_API_KEY")
        if not api_key:
            # Log error or raise a more specific exception
            raise ValueError("GEMINI_API_KEY environment variable not found!")

        model = ChatGoogleGenerativeAI(
            model=self.model_name,
            temperature=self.temperature,
            max_output_tokens=self.max_tokens, # Gemini uses max_output_tokens
            google_api_key=api_key, # Explicitly pass the API key
            # convert_system_message_to_human=True # May be needed depending on prompt structure, can add if issues arise
        )
        return model


def pack_examples(examples: list[dict]) -> list[dict]:
    """Pack the examples into a list of dictionaries."""
    packed_examples = []
    for example in examples:
        packed_examples.append(
            {
                "role": "user",
                "content": str(example["input"]),
            }
        )
        packed_examples.append(
            {
                "role": "assistant",
                "content": str(example["expected_output"]),
            }
        )

    return packed_examples
