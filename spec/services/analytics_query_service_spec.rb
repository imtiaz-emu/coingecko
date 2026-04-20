require 'rails_helper'

RSpec.describe AnalyticsQueryService do
  subject(:service) { described_class.new }
  let!(:short_url)  { create(:short_url) }

  it "returns zero counts when no clicks" do
    result = service.call(short_url: short_url)
    expect(result.value[:total_clicks]).to eq(0)
  end

  it "counts clicks correctly" do
    create_list(:click_event, 3, short_url: short_url, clicked_at: 1.day.ago)
    expect(service.call(short_url: short_url).value[:total_clicks]).to eq(3)
  end

  it "excludes clicks older than 90 days" do
    create(:click_event, short_url: short_url, clicked_at: 91.days.ago)
    expect(service.call(short_url: short_url).value[:total_clicks]).to eq(0)
  end

  it "paginates recent clicks" do
    create_list(:click_event, 25, short_url: short_url, clicked_at: 1.hour.ago)
    result = service.call(short_url: short_url, page: 2, per_page: 20)
    expect(result.value[:recent_clicks].count).to eq(5)
  end
end
