require "rails_helper"

RSpec.describe TitleFetchService do
  subject(:service) { described_class.new }

  it "extracts page title from HTML" do
    stub_request(:get, "https://example.com/")
      .to_return(status: 200,
                 body: "<html><head><title>Hello</title></head></html>",
                 headers: { "Content-Type" => "text/html" })
    expect(service.call("https://example.com/")).to eq("Hello")
  end

  it "returns nil for non-HTML content type" do
    stub_request(:get, "https://example.com/file.pdf")
      .to_return(status: 200, body: "%PDF",
                 headers: { "Content-Type" => "application/pdf" })
    expect(service.call("https://example.com/file.pdf")).to be_nil
  end

  it "returns nil on HTTP error" do
    stub_request(:get, "https://example.com/404").to_return(status: 404, body: "")
    expect(service.call("https://example.com/404")).to be_nil
  end

  it "returns nil on timeout" do
    stub_request(:get, "https://example.com/slow").to_timeout
    expect(service.call("https://example.com/slow")).to be_nil
  end
end
