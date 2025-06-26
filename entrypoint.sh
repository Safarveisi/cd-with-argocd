#!/bin/sh

echo "🚀 Startup message: ${STARTUP_MESSAGE:-Hello from Alpine!}"
echo "📅 Current date and time: $(date)"
echo "🧑 Running as: $(whoami)"
echo "📁 Working directory: $(pwd)"
echo "✅ Container started successfully."

for i in $(seq 1 $SLEEP_DURATION); do
  echo "⏱️  Running... (${i}s)"
  sleep 1
done
