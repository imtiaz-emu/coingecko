require "ipaddr"
require "resolv"
require "uri"

class UrlValidator
  ALLOWED_SCHEMES = %w[http https].freeze
  MAX_URL_LENGTH  = 2048
  PRIVATE_RANGES  = %w[
    10.0.0.0/8
    172.16.0.0/12
    192.168.0.0/16
    127.0.0.0/8
    169.254.0.0/16
    ::1/128
    fc00::/7
  ].map { |r| IPAddr.new(r) }.freeze

  def call(url_string)
    return Result.failure(:url_blank)      if url_string.blank?
    return Result.failure(:url_too_long)   if url_string.length > MAX_URL_LENGTH

    uri = URI.parse(url_string)
    return Result.failure(:invalid_scheme) unless ALLOWED_SCHEMES.include?(uri.scheme)
    return Result.failure(:missing_host)   if uri.host.blank?

    ips = Resolv.getaddresses(uri.host)
    return Result.failure(:private_address) if ips.empty?
    return Result.failure(:private_address) if ips.any? { |ip| private_ip?(ip) }

    Result.success(uri.to_s)
  rescue URI::InvalidURIError
    Result.failure(:malformed_url)
  end

  private

  def private_ip?(ip_string)
    addr = IPAddr.new(ip_string)
    PRIVATE_RANGES.any? { |range| range.include?(addr) }
  rescue IPAddr::InvalidAddressError
    true
  end
end
