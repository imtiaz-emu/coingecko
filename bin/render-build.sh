#!/usr/bin/env bash
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate

# Download GeoLite2-City database if a MaxMind license key is provided
if [ -n "$MAXMIND_LICENSE_KEY" ]; then
  echo "Downloading GeoLite2-City.mmdb..."
  curl -fsSL \
    "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${MAXMIND_LICENSE_KEY}&suffix=tar.gz" \
    -o /tmp/GeoLite2-City.tar.gz
  TMPDIR=$(mktemp -d)
  tar -xzf /tmp/GeoLite2-City.tar.gz -C "$TMPDIR" --strip-components=1
  cp "$TMPDIR/GeoLite2-City.mmdb" db/GeoLite2-City.mmdb
  rm -rf "$TMPDIR" /tmp/GeoLite2-City.tar.gz
  echo "GeoLite2-City.mmdb installed at db/GeoLite2-City.mmdb"
else
  echo "MAXMIND_LICENSE_KEY not set — skipping GeoIP database download."
fi
