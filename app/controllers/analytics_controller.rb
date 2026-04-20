class AnalyticsController < ApplicationController
  def show
    @short_url = ShortUrl.find_by(short_code: params[:short_code])
    return render "pages/not_found", status: :not_found unless @short_url

    result = AnalyticsQueryService.new.call(
      short_url: @short_url,
      page:      params.fetch(:page, 1).to_i
    )
    @report = result.value
  end
end
