class VotePersistenceJob < ApplicationJob
  queue_as :default

  def perform(payload)
    vote_data = payload.with_indifferent_access

    Vote.create!(
      wall_id: vote_data[:wall_id],
      participant_id: vote_data[:participant_id],
      ip_address: vote_data[:ip_address],
      user_agent: vote_data[:user_agent],
      created_at: vote_data[:voted_at],
      updated_at: vote_data[:voted_at]
    )

    Rails.logger.info(
      event: "vote.persisted",
      wall_id: vote_data[:wall_id],
      participant_id: vote_data[:participant_id]
    )
  rescue StandardError => error
    Rails.logger.error(
      event: "vote.persistence_failed",
      error: error.message,
      error_class: error.class.name,
      payload: vote_data
    )

    raise
  end
end