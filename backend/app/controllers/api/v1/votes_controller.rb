class Api::V1::VotesController < ApplicationController
  def create
    result = VoteService.new(
      participant_id: vote_params[:participant_id],
      request: request
    ).call

    render json: result.payload, status: result.status
  end

  private

  def vote_params
    params.permit(:participant_id)
  end
end