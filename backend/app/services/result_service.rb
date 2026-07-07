class ResultService
  def call
    return no_active_wall unless active_wall

    total_votes = VoteCounter.total_wall_votes(
      wall_id: active_wall.id
    )

    participants = active_wall.participants.map do |participant|
      votes_count = VoteCounter.total_for(
        wall_id: active_wall.id,
        participant_id: participant.id
      )

      {
        id: participant.id,
        name: participant.name,
        votes: votes_count,
        percentage: percentage(votes_count, total_votes)
      }
    end

    ServiceResult.new(
      status: :ok,
      payload: {
        wall: {
          id: active_wall.id,
          name: active_wall.name
        },
        total_votes: total_votes,
        participants: participants
      }
    )
  end

  private

  def active_wall
    @active_wall ||= Wall.active.first
  end

  def percentage(votes_count, total_votes)
    return 0.0 if total_votes.zero?

    ((votes_count.to_f / total_votes) * 100).round(2)
  end

  def no_active_wall
    ServiceResult.new(
      status: :not_found,
      payload: {
        success: false,
        error: "No active wall found"
      }
    )
  end
end