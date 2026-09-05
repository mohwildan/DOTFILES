#!/bin/bash
# ==============================================================================
# Background Synchronizer (Disguised Notification & Audio Cue)
# ==============================================================================

PROJECT_DIR="/Users/mac/project/sibermu-lms-scraping"
PYTHON_BIN="$PROJECT_DIR/venv/bin/python3"

cd "$PROJECT_DIR" || exit 1

"$PYTHON_BIN" -u "$PROJECT_DIR/scraping.py" > /dev/null 2>&1
exit $?
