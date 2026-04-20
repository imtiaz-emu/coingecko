class RedirectService
  def initialize(cache: ShortUrlCache.new)
    @cache = cache
  end

  def call(short_code:)
    cached = safe_cache_fetch(short_code)
    if cached
      return Result.success({ target_url: cached[:target_url], id: cached[:id], cache_hit: true })
    end

    short_url = ShortUrl.find_by(short_code: short_code)
    return Result.failure(:not_found) unless short_url

    safe_cache_store(short_url)
    Result.success({ target_url: short_url.target_url, id: short_url.id, cache_hit: false })
  end

  private

  def safe_cache_fetch(code)
    @cache.fetch(code)
  rescue => e
    Rails.logger.warn("[RedirectService] cache fetch failed: #{e.message}")
    nil
  end

  def safe_cache_store(short_url)
    @cache.store(short_url.short_code, target_url: short_url.target_url, id: short_url.id)
  rescue => e
    Rails.logger.warn("[RedirectService] cache store failed: #{e.message}")
  end
end
