require 'rails_helper'

RSpec.describe ShortUrl, type: :model do
  subject { build(:short_url) }

  it { is_expected.to validate_presence_of(:target_url) }
  it { is_expected.to validate_presence_of(:short_code) }
  it { is_expected.to validate_uniqueness_of(:short_code) }
  it { is_expected.to validate_length_of(:short_code).is_at_most(15) }
  it { is_expected.to validate_length_of(:target_url).is_at_most(2048) }

  it "rejects short_code with spaces" do
    expect(build(:short_url, short_code: "has space")).not_to be_valid
  end

  it "accepts short_code with hyphens and underscores" do
    expect(build(:short_url, short_code: "my-code_1")).to be_valid
  end

  describe "#title_pending?" do
    it "returns true when title and title_fetched_at are nil" do
      expect(build(:short_url, title: nil, title_fetched_at: nil).title_pending?).to be true
    end

    it "returns false when title_fetched_at is set" do
      expect(build(:short_url, title_fetched_at: Time.current).title_pending?).to be false
    end
  end

  describe "#full_short_url" do
    it "returns the complete URL" do
      su = build(:short_url, short_code: "abc123")
      expect(su.full_short_url("shrtn.io")).to eq("https://shrtn.io/abc123")
    end
  end
end
