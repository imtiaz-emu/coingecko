require "rails_helper"

RSpec.describe "Analytics page", type: :system do
  let!(:short_url) { create(:short_url, short_code: "abc123") }

  it "user visits stats page and sees total clicks" do
    create_list(:click_event, 2, short_url: short_url, clicked_at: 1.hour.ago)
    visit analytics_path("abc123")

    expect(page).to have_content("2")
    expect(page).to have_content("Total Clicks")
  end

  it "shows country table when geo data is present" do
    create(:click_event, short_url: short_url, clicked_at: 1.hour.ago,
                         country: "Germany", geo_resolved_at: Time.current)
    visit analytics_path("abc123")

    expect(page).to have_content("Germany")
  end
end
