Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.script_src  :self, "https://cdn.jsdelivr.net"
    policy.style_src   :self, :unsafe_inline, "https://cdn.jsdelivr.net"
    policy.img_src     :self, :data
    policy.connect_src :self
    policy.frame_ancestors :none
  end
end
