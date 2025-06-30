#!/bin/sh

echo "${STARTUP_MESSAGE:-Hello, World!}"
python app/main.py
echo "${PASS1:-You} ${PASS2:-Made it!}"
echo "🛌 Sleeping for $SLEEP_DURATION seconds..."
sleep "$SLEEP_DURATION"
