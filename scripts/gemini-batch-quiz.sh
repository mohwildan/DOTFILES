#!/bin/bash
# ==============================================================================
# Gemini Quiz Batch Sender Wrapper (100% Silent Background)
# ==============================================================================

PYTHON_BIN="/Users/mac/project/sibermu-lms-scraping/venv/bin/python3"
SCRIPT_PATH="/Users/mac/project/sibermu-lms-scraping/gemini_batch_sender.py"

cd "/Users/mac/project/sibermu-lms-scraping" || exit 1
"$PYTHON_BIN" "$SCRIPT_PATH" "$@" > /dev/null 2>&1
exit 0
