require "rails_helper"

RSpec.describe "GET /:short_code", type: :request do
  let!(:short_url) { create(:short_url, short_code: "abc123", target_url: "https://example.com") }
  let(:mock_cache) { instance_double(ShortUrlCache, fetch: nil, store: nil) }

  before do
    allow(ShortUrlCache).to receive(:new).and_return(mock_cache)
    allow(ClickRecordJob).to receive(:perform_later)
  end

  it "redirects to the target URL with 302" do
    get "/abc123"
    expect(response).to have_http_status(:found)
    expect(response.location).to eq("https://example.com")
  end

  it "sets Cache-Control: no-store on redirect" do
    get "/abc123"
    expect(response.headers["Cache-Control"]).to include("no-store")
  end

  it "enqueues ClickRecordJob on successful redirect" do
    expect(ClickRecordJob).to receive(:perform_later).once
    get "/abc123"
  end

  it "returns 404 for an unknown short code" do
    get "/missing"
    expect(response).to have_http_status(:not_found)
  end
end
