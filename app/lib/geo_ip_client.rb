class GeoIpClient
  DB_PATH = Rails.root.join("db", "GeoLite2-City.mmdb").to_s

  def initialize
    @reader = File.exist?(DB_PATH) ? MaxMind::DB.new(DB_PATH, mode: MaxMind::DB::MODE_MEMORY) : nil
  end

  def lookup(ip_address)
    return null_result unless @reader

    record = @reader.get(ip_address.to_s)
    return null_result unless record

    {
      country: record.dig("country", "names", "en"),
      region:  record.dig("subdivisions", 0, "names", "en"),
      city:    record.dig("city", "names", "en")
    }
  rescue StandardError => e
    Rails.logger.error("[GeoIpClient] lookup failed for #{ip_address.inspect}: #{e.class} #{e.message}")
    null_result
  end

  private

  def null_result
    { country: nil, region: nil, city: nil }
  end
end
