#!/bin/bash
set -e

# Check the first argument
# If it's one of our handled cases, then strip it off (shift 1) and pass the rest to `python -m factcheck`.
if [ "$1" = "factcheck" ]; then
    shift 1
    exec python -m factcheck "$@" --client local_openai --model DeepSeek-R1-Distill-Qwen-32B
elif [ "$1" = "factcheck-webapp" ]; then
    shift 1
    exec python webapp.py "$@" --client local_openai --model DeepSeek-R1-Distill-Qwen-32B

# Otherwise, execute the given command verbatim
else
    exec "$@"
fi
