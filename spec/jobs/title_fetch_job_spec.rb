require "rails_helper"

RSpec.describe TitleFetchJob, type: :job do
  let!(:su) { create(:short_url, title: nil, title_fetched_at: nil) }

  it "updates title and title_fetched_at" do
    allow_any_instance_of(TitleFetchService).to receive(:call).and_return("Fetched Title")
    described_class.perform_now(su.id)
    su.reload
    expect(su.title).to eq("Fetched Title")
    expect(su.title_fetched_at).not_to be_nil
  end

  it "is idempotent when title_fetched_at is already set" do
    su.update!(title_fetched_at: Time.current)
    expect_any_instance_of(TitleFetchService).not_to receive(:call)
    described_class.perform_now(su.id)
  end

  it "does nothing when short_url does not exist" do
    expect_any_instance_of(TitleFetchService).not_to receive(:call)
    described_class.perform_now(0)
  end
end
