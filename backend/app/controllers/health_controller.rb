class HealthController < ApplicationController
  def show
    render json: {
      status: "ok",
      database: database_status,
      redis: redis_status
    }, status: :ok
  end

  private

  def database_status
    ActiveRecord::Base.connection.execute("SELECT 1")
    "up"
  rescue StandardError
    "down"
  end

  def redis_status
    REDIS.ping == "PONG" ? "up" : "down"
  rescue StandardError
    "down"
  end
end