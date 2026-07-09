require "uri"
redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")

if Rails.env.test?
  uri = URI.parse(redis_url)
  uri.path = "/1"
  redis_url = uri.to_s
end

REDIS = Redis.new(url: redis_url)