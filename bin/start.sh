#!/usr/bin/env bash
set -e

# Start Sidekiq in the background
bundle exec sidekiq -C config/sidekiq.yml &

# Start Puma in the foreground (container lives as long as Puma does)
exec bundle exec puma -C config/puma.rb
