FactoryBot.define do
  factory :short_url do
    sequence(:short_code) { |n| "code#{n.to_s.rjust(4, "0")}" }
    target_url { "https://example.com/page" }
    title      { "Example Page Title" }
  end
end
