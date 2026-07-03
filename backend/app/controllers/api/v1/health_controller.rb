class Api::V1::HealthController < ApplicationController
  def index
    render json: {
          status: "ok",
          service: "bbb-voting-api",
          version: "1.0.0",
          timestamp: Time.current.iso8601
        }, status: :ok
  end
end
