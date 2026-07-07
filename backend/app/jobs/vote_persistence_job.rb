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
  end
end