require 'rails_helper'

RSpec.describe ShortUrlCache do
  let(:redis) { Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1")) }
  subject(:cache) { described_class.new(redis: redis) }

  before { redis.flushdb }
  after  { redis.flushdb }

  it "stores and retrieves a value" do
    cache.store("abc", target_url: "https://example.com", id: 1)
    result = cache.fetch("abc")
    expect(result[:target_url]).to eq("https://example.com")
    expect(result[:id]).to eq(1)
  end

  it("returns nil for a missing key") { expect(cache.fetch("missing")).to be_nil }

  it "invalidates a key" do
    cache.store("abc", target_url: "https://example.com", id: 1)
    cache.invalidate("abc")
    expect(cache.fetch("abc")).to be_nil
  end
end
