FactoryBot.define do
  factory :click_event do
    association :short_url
    clicked_at  { Time.current }
    ip_address  { "203.0.113.#{rand(1..254)}" }  # TEST-NET-3 — safe for specs
    user_agent  { "Mozilla/5.0 (Test)" }
  end
end
