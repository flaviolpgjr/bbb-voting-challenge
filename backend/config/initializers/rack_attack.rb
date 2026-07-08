class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  throttle("votes/ip", limit: 20, period: 10.seconds) do |request|
    if request.path == "/api/v1/votes" && request.post?
      request.ip
    end
  end

  self.throttled_responder = lambda do |request|
    Rails.logger.warn(
      event: "vote.rate_limited",
      ip_address: request.ip,
      path: request.path
    )

    [
      429,
      { "Content-Type" => "application/json" },
      [{ success: false, error: "Too many votes. Please slow down." }.to_json]
    ]
  end
end