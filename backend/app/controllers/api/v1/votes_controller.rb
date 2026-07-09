class Api::V1::VotesController < ApplicationController
  def create
    result = VoteService.new(
      participant_id: vote_params[:participant_id],
      request: request,
      website: vote_params[:website],
      rendered_at: vote_params[:rendered_at]
    ).call

    render json: result.payload, status: result.status
  end

  private

  def vote_params
    params.permit(:participant_id, :website, :rendered_at)
  end
end