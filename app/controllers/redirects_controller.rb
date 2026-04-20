class RedirectsController < ApplicationController
  def show
    result = RedirectService.new.call(short_code: params[:short_code])

    if result.success?
      data = result.value
      ClickRecordJob.perform_later(
        short_url_id: data[:id],
        ip_address:   anonymise_ip(request.remote_ip),
        user_agent:   request.user_agent.to_s.truncate(500),
        referrer:     request.referer.to_s.truncate(2048),
        clicked_at:   Time.current.iso8601
      )
      response.set_header("Cache-Control", "no-store, no-cache")
      redirect_to data[:target_url], status: :found, allow_other_host: true
    else
      render "pages/not_found", status: :not_found
    end
  end

  private

  def anonymise_ip(ip)
    addr = IPAddr.new(ip)
    addr.ipv4? ? addr.mask(24).to_s : addr.mask(48).to_s
  rescue IPAddr::InvalidAddressError
    nil
  end
end
