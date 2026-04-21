class Rack::Attack
  # Back the cache with Redis
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
    pool: false
  )

  # 10 URL creations per minute per IP
  throttle("short_url/create", limit: 10, period: 60) do |req|
    req.ip if req.post? && req.path.in?([ "/s", "/api/v1/short_urls" ])
  end

  # 120 redirects per minute per IP
  throttle("redirects", limit: 120, period: 60) do |req|
    req.ip if req.get? && req.path.match?(/\A\/[a-zA-Z0-9_\-]{1,15}\z/)
  end

  self.throttled_responder = lambda do |req|
    if req.path.start_with?("/api/")
      [ 429, { "Content-Type" => "application/json" },
       [ { errors: [ { code: "rate_limit_exceeded" } ] }.to_json ] ]
    else
      [ 429, { "Content-Type" => "text/html" },
       [ "<h1>Too many requests</h1><p>Please slow down.</p>" ] ]
    end
  end
end
