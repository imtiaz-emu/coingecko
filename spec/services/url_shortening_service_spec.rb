require 'rails_helper'

RSpec.describe UrlShorteningService do
  subject(:service) { described_class.new }
  let(:valid_url)   { "https://example.com/page" }

  before do
    allow_any_instance_of(UrlValidator).to receive(:call)
      .and_return(Result.success(valid_url))
    allow_any_instance_of(ShortCodeGenerator).to receive(:generate_unique)
      .and_return(Result.success("abc12345"))
    allow(TitleFetchJob).to receive(:perform_later)
  end

  it "creates a ShortUrl and returns success" do
    result = service.call(target_url: valid_url)
    expect(result.success?).to be true
    expect(result.value).to be_a(ShortUrl)
    expect(result.value.short_code).to eq("abc12345")
  end

  it "enqueues TitleFetchJob on success" do
    expect(TitleFetchJob).to receive(:perform_later)
    service.call(target_url: valid_url)
  end

  it "returns failure when URL validation fails" do
    allow_any_instance_of(UrlValidator).to receive(:call)
      .and_return(Result.failure(:invalid_scheme))
    expect(service.call(target_url: "ftp://x.com").error).to eq(:invalid_scheme)
  end

  it "returns failure when code generation is exhausted" do
    allow_any_instance_of(ShortCodeGenerator).to receive(:generate_unique)
      .and_return(Result.failure(:collision_exhausted))
    expect(service.call(target_url: valid_url).error).to eq(:collision_exhausted)
  end

  context "with a custom slug" do
    it "accepts a valid available slug" do
      result = service.call(target_url: valid_url, custom_slug: "my-brand")
      expect(result.value.short_code).to eq("my-brand")
    end

    it("rejects a reserved slug")      { expect(service.call(target_url: valid_url, custom_slug: "health").error).to eq(:slug_reserved) }
    it("rejects a slug over 15 chars") { expect(service.call(target_url: valid_url, custom_slug: "a" * 16).error).to eq(:slug_too_long) }

    it "rejects a taken slug" do
      create(:short_url, short_code: "taken")
      expect(service.call(target_url: valid_url, custom_slug: "taken").error).to eq(:slug_taken)
    end
  end
end
