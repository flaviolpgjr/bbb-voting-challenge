class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  throttle_limit = ENV.fetch("RACK_ATTACK_LIMIT", 20).to_i
  throttle_period = ENV.fetch("RACK_ATTACK_PERIOD", 10).to_i.seconds

  throttle("votes/ip", limit: throttle_limit, period: throttle_period) do |request|
    request.ip if request.path == "/api/v1/votes" && request.post?
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