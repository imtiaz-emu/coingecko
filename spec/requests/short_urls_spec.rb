require "rails_helper"

RSpec.describe "POST /api/v1/short_urls", type: :request do
  let(:valid_url) { "https://example.com/page" }
  let(:headers)   { { "Content-Type" => "application/json" } }

  before do
    allow_any_instance_of(UrlValidator).to receive(:call)
      .and_return(Result.success(valid_url))
    allow_any_instance_of(ShortCodeGenerator).to receive(:generate_unique)
      .and_return(Result.success("abc12345"))
    allow(TitleFetchJob).to receive(:perform_later)
  end

  it "returns 201 with a valid URL" do
    post "/api/v1/short_urls",
         params:  { short_url: { target_url: valid_url } }.to_json,
         headers: headers
    expect(response).to have_http_status(:created)
    body = JSON.parse(response.body)
    expect(body.dig("data", "short_code")).to eq("abc12345")
  end

  it "returns 422 when URL validation fails" do
    allow_any_instance_of(UrlValidator).to receive(:call)
      .and_return(Result.failure(:invalid_scheme))
    post "/api/v1/short_urls",
         params:  { short_url: { target_url: "ftp://bad.com" } }.to_json,
         headers: headers
    expect(response).to have_http_status(:unprocessable_content)
    expect(JSON.parse(response.body).dig("errors", 0, "code")).to eq("invalid_scheme")
  end

  it "returns 201 with a valid custom slug" do
    post "/api/v1/short_urls",
         params:  { short_url: { target_url: valid_url, custom_slug: "my-brand" } }.to_json,
         headers: headers
    expect(response).to have_http_status(:created)
    expect(JSON.parse(response.body).dig("data", "short_code")).to eq("my-brand")
  end

  it "returns 422 with a taken custom slug" do
    create(:short_url, short_code: "taken")
    post "/api/v1/short_urls",
         params:  { short_url: { target_url: valid_url, custom_slug: "taken" } }.to_json,
         headers: headers
    expect(response).to have_http_status(:unprocessable_content)
    expect(JSON.parse(response.body).dig("errors", 0, "code")).to eq("slug_taken")
  end
end
