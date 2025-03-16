import time
import openai
from openai import OpenAI
from .base import BaseClient


class LocalOpenAIClient(BaseClient):
    """Support Local host LLM chatbot with OpenAI API.
    see https://github.com/lm-sys/FastChat/blob/main/docs/openai_api.md for example usage.
    """

    def __init__(
        self,
        model: str = "",
        api_config: dict = None,
        max_requests_per_minute=200,
        request_window=60,
    ):
        super().__init__(model, api_config, max_requests_per_minute, request_window)

        openai.api_key = api_config["LOCAL_API_KEY"]
        openai.base_url = api_config["LOCAL_API_URL"]

    def _call(self, messages: str, **kwargs):
        seed = kwargs.get("seed", 42)  # default seed is 42
        temperature = kwargs.get("temperature", 0.0)
        assert type(seed) is int, "Seed must be an integer."

        response = openai.chat.completions.create(
            response_format={"type": "json_object"},
            seed=seed,
            temperature=temperature,
            model=self.model,
            messages=messages,
        )
        r = response.choices[0].message.content
        return r

    def get_request_length(self, messages):
        # TODO: check if we should return the len(menages) instead
        return 1

    def construct_message_list(
        self,
        prompt_list: list[str],
        system_role: str = "You are a helpful assistant designed to output valid JSON and nothing else.\n\nFollow these rules carefully:\n1. Do not include any code fences (like ```json).\n2. Do not include explanations, apologies, or extra text before or after the JSON.\n3. The entire response must be valid JSON, and must parse without error.\n\nOnly return the JSON object for your final output.",
    ):
        messages_list = list()
        for prompt in prompt_list:
            messages = [
                {"role": "system", "content": system_role},
                {"role": "user", "content": prompt},
            ]
            messages_list.append(messages)
        return messages_list
