require "rails_helper"

RSpec.describe GeoIpResolveJob, type: :job do
  let!(:event) { create(:click_event, ip_address: "8.8.8.8", geo_resolved_at: nil) }

  it "populates geo fields" do
    allow_any_instance_of(GeoIpClient).to receive(:lookup)
      .and_return({ country: "US", region: "CA", city: "Mountain View" })
    described_class.perform_now(event.id)
    event.reload
    expect(event.country).to eq("US")
    expect(event.geo_resolved_at).not_to be_nil
  end

  it "is idempotent when geo_resolved_at is already set" do
    event.update!(geo_resolved_at: Time.current)
    expect_any_instance_of(GeoIpClient).not_to receive(:lookup)
    described_class.perform_now(event.id)
  end

  it "does nothing when click_event does not exist" do
    expect_any_instance_of(GeoIpClient).not_to receive(:lookup)
    described_class.perform_now(0)
  end
end
