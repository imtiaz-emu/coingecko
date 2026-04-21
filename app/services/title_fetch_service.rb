class TitleFetchService
  TIMEOUT       = 5
  MAX_REDIRECTS = 3

  def call(url)
    conn = Faraday.new do |f|
      f.use Faraday::FollowRedirects::Middleware, limit: MAX_REDIRECTS
      f.options.timeout      = TIMEOUT
      f.options.open_timeout = TIMEOUT
    end
    response = conn.get(url)
    return nil unless response.success?
    return nil unless response.headers["content-type"].to_s.include?("text/html")

    Nokogiri::HTML(response.body).at_css("title")&.text&.strip&.slice(0, 500).presence
  rescue Faraday::Error, URI::InvalidURIError
    nil
  end
end
