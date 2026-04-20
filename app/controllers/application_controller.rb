class ApplicationController < ActionController::Base
  before_action :set_security_headers

  private

  def set_security_headers
    response.set_header("X-Frame-Options",        "DENY")
    response.set_header("X-Content-Type-Options", "nosniff")
    response.set_header("Referrer-Policy",        "strict-origin-when-cross-origin")
  end
end
