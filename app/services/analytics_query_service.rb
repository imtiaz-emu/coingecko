class AnalyticsQueryService
  RETENTION_DAYS   = 90
  DEFAULT_PER_PAGE = 20

  def call(short_url:, page: 1, per_page: DEFAULT_PER_PAGE)
    since  = RETENTION_DAYS.days.ago
    events = short_url.click_events.since(since)

    Result.success({
      short_url:         short_url,
      total_clicks:      events.count,
      clicks_by_day:     clicks_by_day(events),
      clicks_by_country: clicks_by_country(events),
      recent_clicks:     paginate(events, page, per_page),
      current_page:      page,
      per_page:          per_page
    })
  end

  private

  def clicks_by_day(events)
    events.group("DATE(clicked_at)").order("DATE(clicked_at) ASC").count
          .map { |date, count| { date: date.to_s, count: count } }
  end

  def clicks_by_country(events)
    events.where.not(country: nil).group(:country).order("count_all DESC").limit(20).count
          .map { |country, count| { country: country, count: count } }
  end

  def paginate(events, page, per_page)
    events.recent.offset((page - 1) * per_page).limit(per_page)
  end
end
