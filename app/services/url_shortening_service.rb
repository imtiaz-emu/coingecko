class UrlShorteningService
  RESERVED_SLUGS = %w[
    health ready api admin robots.txt sitemap.xml
    favicon.ico assets packs cable sidekiq s
  ].freeze

  def initialize(
    validator:      UrlValidator.new,
    code_generator: ShortCodeGenerator.new
  )
    @validator      = validator
    @code_generator = code_generator
  end

  def call(target_url:, custom_slug: nil)
    validation = @validator.call(target_url.to_s.strip)
    return validation if validation.failure?

    short_code = if custom_slug.present?
      slug_result = validate_custom_slug(custom_slug.strip)
      return slug_result if slug_result.failure?
      custom_slug.strip
    else
      code_result = @code_generator.generate_unique
      return code_result if code_result.failure?
      code_result.value
    end

    short_url = ShortUrl.create!(short_code: short_code, target_url: validation.value)
    TitleFetchJob.perform_later(short_url.id)
    Result.success(short_url)
  rescue ActiveRecord::RecordNotUnique
    Result.failure(:slug_taken)
  end

  private

  def validate_custom_slug(slug)
    return Result.failure(:slug_reserved)      if RESERVED_SLUGS.include?(slug.downcase)
    return Result.failure(:slug_taken)         if ShortUrl.exists?(short_code: slug)
    return Result.failure(:slug_too_long)      if slug.length > 15
    return Result.failure(:slug_invalid_chars) unless slug.match?(/\A[a-zA-Z0-9_-]+\z/)
    Result.success(slug)
  end
end
