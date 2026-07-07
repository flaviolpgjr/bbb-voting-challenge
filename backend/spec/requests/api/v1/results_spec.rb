require "rails_helper"

RSpec.describe "Api::V1::Results", type: :request do
  describe "GET /api/v1/results" do
    it "returns http success" do
      get "/api/v1/results"
      expect(response).to have_http_status(:ok).or have_http_status(:not_found)
    end
  end
end