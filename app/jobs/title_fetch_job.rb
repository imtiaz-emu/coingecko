class TitleFetchJob < ApplicationJob
  queue_as :title_fetch
  sidekiq_options retry: 3

  def perform(short_url_id)
    su = ShortUrl.find_by(id: short_url_id)
    return unless su
    return if su.title_fetched_at.present?

    title = TitleFetchService.new.call(su.target_url)
    su.update!(title: title, title_fetched_at: Time.current)
  end
end
