require 'rails_helper'

RSpec.describe Result do
  it "success holds a value and reports success?" do
    r = Result.success("hello")
    expect(r.success?).to be true
    expect(r.value).to eq("hello")
    expect(r.error).to be_nil
  end

  it "failure holds an error code and reports failure?" do
    r = Result.failure(:not_found)
    expect(r.failure?).to be true
    expect(r.error).to eq(:not_found)
    expect(r.value).to be_nil
  end
end
