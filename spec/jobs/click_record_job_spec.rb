require "rails_helper"

RSpec.describe ClickRecordJob, type: :job do
  let!(:short_url) { create(:short_url) }

  it "creates a click_event" do
    allow(GeoIpResolveJob).to receive(:perform_later)
    expect do
      described_class.perform_now(
        short_url_id: short_url.id, ip_address: "203.0.113.1",
        user_agent: "Test", referrer: "", clicked_at: Time.current.iso8601
      )
    end.to change(ClickEvent, :count).by(1)
  end

  it "enqueues GeoIpResolveJob" do
    expect(GeoIpResolveJob).to receive(:perform_later)
    described_class.perform_now(
      short_url_id: short_url.id, ip_address: "203.0.113.1",
      user_agent: "", referrer: "", clicked_at: Time.current.iso8601
    )
  end

  it "is idempotent when short_url does not exist" do
    allow(GeoIpResolveJob).to receive(:perform_later)
    expect do
      described_class.perform_now(
        short_url_id: 0, ip_address: "", user_agent: "",
        referrer: "", clicked_at: Time.current.iso8601
      )
    end.not_to change(ClickEvent, :count)
  end
end
