#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title OCR Create Event
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖

# --- Step 1: Screenshot full screen (avoid Arc window bug) ---
# Ask user to select an area
screenshot_path="$HOME/Downloads/selected_area.png"
clean_path="$HOME/Downloads/selected_area_clean.png"

# Open interactive selection (crosshair selection, just like Shift+Cmd+4)
screencapture -i -x "$screenshot_path"

# Convert to clean PNG for Tesseract
sips -s format png "$screenshot_path" --out "$clean_path"

# --- Step 2: OCR ---
ocr_text=$(tesseract "$screenshot_path" stdout -l eng 2>/dev/null)

if [ -z "$ocr_text" ]; then
  echo "No text found on screen"
  exit 1
fi

# --- Step 3: Run local AI model via Ollama ---
now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
event_json=$(echo "NOW is $now. Extract a calendar event from this text: $ocr_text" | ollama run capturevent)

# --- Step 4: Parse JSON ---
title=$(echo "$event_json" | jq -r '.title')
description=$(echo "$event_json" | jq -r '.description')
url=$(echo "$event_json" | jq -r '.url')
start=$(echo "$event_json" | jq -r '.start')
end=$(echo "$event_json" | jq -r '.end')

# --- Step 5: Convert ISO -> AppleScript date format ---
start_as=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${start:0:19}" "+%d %b %Y %H:%M:%S")
end_as=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${end:0:19}" "+%d %b %Y %H:%M:%S")

# --- Step 6: Create Calendar event (use first calendar if unsure) ---
osascript <<EOF
tell application "Calendar"
    tell first calendar
        make new event with properties {summary:"$title", description:"$description", url:"$url", start date:date "$start_as", end date:date "$end_as"}
    end tell
end tell
EOF
