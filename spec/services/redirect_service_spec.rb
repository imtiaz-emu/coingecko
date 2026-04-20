require 'rails_helper'

RSpec.describe RedirectService do
  let(:mock_cache) { instance_double(ShortUrlCache) }
  subject(:service) { described_class.new(cache: mock_cache) }
  let!(:short_url)  { create(:short_url, short_code: "abc123", target_url: "https://example.com") }

  it "returns from cache on hit" do
    allow(mock_cache).to receive(:fetch).and_return({ target_url: "https://example.com", id: short_url.id })
    result = service.call(short_code: "abc123")
    expect(result.success?).to be true
    expect(result.value[:cache_hit]).to be true
  end

  it "falls back to DB on cache miss and stores result" do
    allow(mock_cache).to receive(:fetch).and_return(nil)
    allow(mock_cache).to receive(:store)
    result = service.call(short_code: "abc123")
    expect(result.success?).to be true
    expect(result.value[:cache_hit]).to be false
    expect(mock_cache).to have_received(:store)
  end

  it "returns :not_found for unknown code" do
    allow(mock_cache).to receive(:fetch).and_return(nil)
    expect(service.call(short_code: "nope").error).to eq(:not_found)
  end

  it "falls back to DB when Redis raises" do
    allow(mock_cache).to receive(:fetch).and_raise(Redis::CannotConnectError)
    allow(mock_cache).to receive(:store)
    expect(service.call(short_code: "abc123").success?).to be true
  end
end
