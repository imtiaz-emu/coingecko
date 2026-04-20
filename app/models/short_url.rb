class ShortUrl < ApplicationRecord
  SHORT_CODE_FORMAT = /\A[a-zA-Z0-9_-]+\z/

  has_many :click_events, dependent: :destroy

  validates :target_url,  presence: true, length: { maximum: 2048 }
  validates :short_code,  presence: true,
                          uniqueness: { case_sensitive: true },
                          length: { maximum: 15 },
                          format: { with: SHORT_CODE_FORMAT }
  validates :title,       length: { maximum: 500 }, allow_nil: true

  def title_pending?
    title.nil? && title_fetched_at.nil?
  end

  def full_short_url(host)
    "https://#{host}/#{short_code}"
  end
end
