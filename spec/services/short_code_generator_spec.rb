require 'rails_helper'

RSpec.describe ShortCodeGenerator do
  subject(:gen) { described_class.new }

  describe "#generate" do
    it("returns a string of 8 characters") { expect(gen.generate.length).to eq(8) }
    it("only uses Base62 characters")      { expect(gen.generate).to match(/\A[0-9a-zA-Z]+\z/) }
  end

  describe "#generate_unique" do
    it "returns success with a non-colliding code" do
      allow(ShortUrl).to receive(:exists?).and_return(false)
      expect(gen.generate_unique.success?).to be true
    end

    it "returns failure after max retries" do
      allow(ShortUrl).to receive(:exists?).and_return(true)
      result = gen.generate_unique
      expect(result.failure?).to be true
      expect(result.error).to eq(:collision_exhausted)
    end
  end
end
