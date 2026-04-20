require 'rails_helper'

RSpec.describe UrlValidator do
  subject(:validator) { described_class.new }

  it "accepts a valid HTTPS URL" do
    allow(Resolv).to receive(:getaddresses).and_return([ "93.184.216.34" ])
    expect(validator.call("https://example.com").success?).to be true
  end

  it("rejects blank input")          { expect(validator.call("").error).to eq(:url_blank) }
  it("rejects file:// scheme")       { expect(validator.call("file:///etc/passwd").error).to eq(:invalid_scheme) }
  it("rejects javascript: scheme")   { expect(validator.call("javascript:alert(1)").error).to eq(:invalid_scheme) }
  it("rejects malformed URLs")       { expect(validator.call("not a url").error).to eq(:malformed_url) }

  it "rejects URLs over 2048 chars" do
    expect(validator.call("https://x.com/" + "a" * 2040).error).to eq(:url_too_long)
  end

  %w[127.0.0.1 10.0.0.1 192.168.1.1 172.16.0.1].each do |ip|
    it "rejects URL resolving to private IP #{ip}" do
      allow(Resolv).to receive(:getaddresses).and_return([ ip ])
      expect(validator.call("https://internal.example.com").error).to eq(:private_address)
    end
  end
end
