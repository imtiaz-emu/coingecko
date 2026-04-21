class ClickRecordJob < ApplicationJob
  queue_as :critical

  def perform(short_url_id:, ip_address:, user_agent:, referrer:, clicked_at:)
    short_url = ShortUrl.find_by(id: short_url_id)
    return unless short_url

    event = short_url.click_events.create!(
      clicked_at: Time.parse(clicked_at),
      ip_address: ip_address,
      user_agent: user_agent.presence,
      referrer:   referrer.presence
    )
    GeoIpResolveJob.perform_later(event.id)
  end
end
