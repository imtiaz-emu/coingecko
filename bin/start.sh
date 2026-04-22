#!/usr/bin/env bash
set -e

echo "[start.sh] Starting Sidekiq..."
bundle exec sidekiq -C config/sidekiq.yml >> /tmp/sidekiq.log 2>&1 &
SIDEKIQ_PID=$!
echo "[start.sh] Sidekiq PID: $SIDEKIQ_PID"

# Give Sidekiq a moment to connect to Redis before Puma starts
sleep 2

# Verify Sidekiq is still running
if ! kill -0 $SIDEKIQ_PID 2>/dev/null; then
  echo "[start.sh] Sidekiq failed to start. Sidekiq log:"
  cat /tmp/sidekiq.log
  exit 1
fi

echo "[start.sh] Starting Puma..."
exec bundle exec puma -C config/puma.rb
