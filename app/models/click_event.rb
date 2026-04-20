class ClickEvent < ApplicationRecord
  belongs_to :short_url

  validates :clicked_at, presence: true

  scope :resolved,   -> { where.not(geo_resolved_at: nil) }
  scope :unresolved, -> { where(geo_resolved_at: nil) }
  scope :recent,     -> { order(clicked_at: :desc) }
  scope :since,      ->(time) { where("clicked_at >= ?", time) }
end
