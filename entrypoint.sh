#!/bin/sh

echo "${STARTUP_MESSAGE:-Hello, World!}"
python main.py
echo "🛌 Sleeping for $SLEEP_DURATION seconds..."
sleep "$SLEEP_DURATION"