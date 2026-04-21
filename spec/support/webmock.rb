require "webmock/rspec"

# Allow localhost connections (for real DB/Redis in specs)
WebMock.disable_net_connect!(allow_localhost: true)
