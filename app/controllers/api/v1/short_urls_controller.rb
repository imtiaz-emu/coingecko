module Api
  module V1
    class ShortUrlsController < ApplicationController
      def create
        result = UrlShorteningService.new.call(
          target_url:  short_url_params[:target_url].to_s.strip,
          custom_slug: short_url_params[:custom_slug].presence
        )
        if result.success?
          render json: serialize(result.value), status: :created
        else
          render json: { errors: [ { code: result.error } ] }, status: :unprocessable_content
        end
      end

      def show
        su = ShortUrl.find_by(short_code: params[:short_code])
        return render json: { errors: [ { code: "not_found" } ] }, status: :not_found unless su

        render json: serialize(su)
      end

      def analytics
        su = ShortUrl.find_by(short_code: params[:short_code])
        return render json: { errors: [ { code: "not_found" } ] }, status: :not_found unless su

        result = AnalyticsQueryService.new.call(short_url: su, page: params.fetch(:page, 1).to_i)
        render json: result.value.except(:short_url)
      end

      private

      def short_url_params
        params.require(:short_url).permit(:target_url, :custom_slug)
      end

      def serialize(su)
        { data: {
          id:           su.id.to_s,
          short_code:   su.short_code,
          short_url:    su.full_short_url(request.host_with_port),
          target_url:   su.target_url,
          title:        su.title,
          title_status: su.title_pending? ? "pending" : "resolved",
          created_at:   su.created_at.iso8601
        } }
      end
    end
  end
end
