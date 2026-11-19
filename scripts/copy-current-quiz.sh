#!/bin/bash
# Copy currently active quiz page/question from Chrome
PROJECT_DIR="/Users/mac/project/sibermu-lms-scraping"
cd "$PROJECT_DIR" || exit 1
"$PROJECT_DIR/venv/bin/python3" "$PROJECT_DIR/copy_current_question.py" > /dev/null 2>&1
exit 0
