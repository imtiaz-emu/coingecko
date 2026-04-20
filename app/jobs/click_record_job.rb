class ClickRecordJob < ApplicationJob
  queue_as :default

  def perform(short_url_id:, ip_address:, user_agent:, referrer:, clicked_at:)
  end
end
