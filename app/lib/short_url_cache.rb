class ShortUrlCache
  KEY_PREFIX = "shrtn:code:"
  TTL        = 24 * 60 * 60

  def initialize(redis: REDIS)
    @redis = redis
  end

  def fetch(short_code)
    raw = @redis.get("#{KEY_PREFIX}#{short_code}")
    return nil unless raw
    @redis.expire("#{KEY_PREFIX}#{short_code}", TTL)
    JSON.parse(raw, symbolize_names: true)
  end

  def store(short_code, target_url:, id:)
    @redis.setex("#{KEY_PREFIX}#{short_code}", TTL,
                 { target_url: target_url, id: id }.to_json)
  end

  def invalidate(short_code)
    @redis.del("#{KEY_PREFIX}#{short_code}")
  end
end
