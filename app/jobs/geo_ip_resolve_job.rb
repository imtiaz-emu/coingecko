class GeoIpResolveJob < ApplicationJob
  queue_as :geo_resolve
  sidekiq_options retry: 3

  def perform(click_event_id)
    event = ClickEvent.find_by(id: click_event_id)
    return unless event
    return if event.geo_resolved_at.present?

    Rails.logger.info("[GeoIpResolveJob] resolving click_event=#{click_event_id} ip=#{event.ip_address.inspect}")
    result = GeoIpClient.new.lookup(event.ip_address.to_s)
    Rails.logger.info("[GeoIpResolveJob] result=#{result.inspect}")
    event.update!(
      country:         result[:country],
      region:          result[:region],
      city:            result[:city],
      geo_resolved_at: Time.current
    )
  end
end
