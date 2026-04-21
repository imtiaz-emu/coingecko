require "rails_helper"

RSpec.describe "Analytics", type: :request do
  let!(:short_url) { create(:short_url, short_code: "abc123") }

  describe "GET /:short_code/stats" do
    it "returns 200 for an existing short URL" do
      get "/abc123/stats"
      expect(response).to have_http_status(:ok)
    end

    it "returns 404 for an unknown short code" do
      get "/missing/stats"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v1/short_urls/:short_code/analytics" do
    before do
      create_list(:click_event, 3, short_url: short_url, clicked_at: 1.day.ago,
                                   country: "US", geo_resolved_at: Time.current)
    end

    it "returns 200 with analytics payload" do
      get "/api/v1/short_urls/abc123/analytics"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["total_clicks"]).to eq(3)
      expect(body).to have_key("clicks_by_day")
      expect(body).to have_key("clicks_by_country")
    end

    it "returns 404 for an unknown short code" do
      get "/api/v1/short_urls/nope/analytics"
      expect(response).to have_http_status(:not_found)
    end

    it "paginates — page 2 of 1-per-page returns the second click" do
      get "/api/v1/short_urls/abc123/analytics?page=2&per_page=1"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["recent_clicks"].length).to eq(1)
      expect(body["current_page"]).to eq(2)
    end
  end
end
