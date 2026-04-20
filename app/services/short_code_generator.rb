class ShortCodeGenerator
  ALPHABET       = (("0".."9").to_a + ("a".."z").to_a + ("A".."Z").to_a).freeze
  DEFAULT_LENGTH = 8
  MAX_RETRIES    = 5

  def initialize(length: DEFAULT_LENGTH)
    @length = length
  end

  def generate
    Array.new(@length) { ALPHABET[SecureRandom.random_number(ALPHABET.size)] }.join
  end

  def generate_unique
    MAX_RETRIES.times do
      code = generate
      return Result.success(code) unless ShortUrl.exists?(short_code: code)
    end
    Result.failure(:collision_exhausted)
  end
end
