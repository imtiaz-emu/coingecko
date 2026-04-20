require 'rails_helper'

RSpec.describe ClickEvent, type: :model do
  it { is_expected.to belong_to(:short_url) }
  it { is_expected.to validate_presence_of(:clicked_at) }

  describe "scopes" do
    let!(:short_url)   { create(:short_url) }
    let!(:geo_done)    { create(:click_event, short_url: short_url, clicked_at: 1.hour.ago,  geo_resolved_at: Time.current) }
    let!(:geo_pending) { create(:click_event, short_url: short_url, clicked_at: 2.hours.ago, geo_resolved_at: nil) }

    it(".resolved returns geo-resolved events")   { expect(ClickEvent.resolved).to contain_exactly(geo_done) }
    it(".unresolved returns pending events")       { expect(ClickEvent.unresolved).to contain_exactly(geo_pending) }
    it(".recent orders descending by clicked_at") { expect(ClickEvent.recent.first).to eq(geo_done) }
    it(".since filters by time")                  { expect(ClickEvent.since(90.minutes.ago)).to contain_exactly(geo_done) }
  end
end
