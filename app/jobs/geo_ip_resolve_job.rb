class GeoIpResolveJob < ApplicationJob
  queue_as :geo_resolve
  sidekiq_options retry: 3

  def perform(click_event_id)
    event = ClickEvent.find_by(id: click_event_id)
    return unless event
    return if event.geo_resolved_at.present?

    result = GeoIpClient.new.lookup(event.ip_address.to_s)
    event.update!(
      country:         result[:country],
      region:          result[:region],
      city:            result[:city],
      geo_resolved_at: Time.current
    )
  end
end
