require 'rails_helper'

RSpec.describe "Metrics", type: :request do
  describe "GET /metrics" do
    it "returns http success" do
      get "/metrics"
      expect(response).to have_http_status(:success)
    end
  end

end
