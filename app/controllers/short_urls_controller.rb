class ShortUrlsController < ApplicationController
  def create
    result = UrlShorteningService.new.call(
      target_url:  params.dig(:short_url, :target_url).to_s.strip,
      custom_slug: params.dig(:short_url, :custom_slug).presence
    )

    if result.success?
      @short_url = result.value
      render "pages/result", status: :created
    else
      @error_key = result.error
      render "pages/home", status: :unprocessable_content
    end
  end
end
