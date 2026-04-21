require "rails_helper"

RSpec.describe "URL shortening", type: :system do
  before do
    allow_any_instance_of(UrlValidator).to receive(:call)
      .and_return(Result.success("https://example.com/page"))
    allow_any_instance_of(ShortCodeGenerator).to receive(:generate_unique)
      .and_return(Result.success("abc12345"))
    allow(TitleFetchJob).to receive(:perform_later)
  end

  it "user submits a valid URL and sees the result page" do
    visit root_path
    fill_in "short_url[target_url]", with: "https://example.com/page"
    click_button "Shorten URL"

    expect(page).to have_content("Your short URL is ready")
    expect(page).to have_field(type: "text", with: /abc12345/)
  end

  it "user submits an invalid URL and sees an error message" do
    allow_any_instance_of(UrlValidator).to receive(:call)
      .and_return(Result.failure(:invalid_scheme))

    visit root_path
    fill_in "short_url[target_url]", with: "ftp://bad.com"
    click_button "Shorten URL"

    expect(page).to have_content("Only http and https URLs are supported.")
  end
end
