require "rails_helper"

RSpec.describe "Security", type: :request do
  describe "SSRF protection" do
    it "blocks POST with a private IP address URL" do
      post "/s", params: { short_url: { target_url: "http://192.168.1.1/secret" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "security headers on redirect" do
    let!(:short_url) { create(:short_url, short_code: "sectest1") }

    it "includes X-Frame-Options: DENY" do
      get "/sectest1"
      expect(response.headers["X-Frame-Options"]).to eq("DENY")
    end

    it "includes Cache-Control: no-store" do
      get "/sectest1"
      expect(response.headers["Cache-Control"]).to include("no-store")
    end
  end

  describe "robots.txt" do
    it "disallows all crawlers" do
      get "/robots.txt"
      expect(response.body).to include("Disallow: /")
    end
  end

  describe "rate limiting" do
    before do
      Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
      Rack::Attack.reset!
    end

    after do
      Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
        url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
        pool: false
      )
    end

    it "returns 429 after exceeding the create throttle" do
      # Pre-seed counter to the limit; next request increments to 11 (> 10) → throttled
      10.times { Rack::Attack.cache.count("short_url/create:127.0.0.1", 60) }
      post "/s", params: { short_url: { target_url: "https://example.com" } }
      expect(response).to have_http_status(429)
    end
  end
end
