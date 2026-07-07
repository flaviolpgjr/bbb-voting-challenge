class Api::V1::ResultsController < ApplicationController
  def index
    result = ResultService.new.call

    render json: result.payload, status: result.status
  end
end
