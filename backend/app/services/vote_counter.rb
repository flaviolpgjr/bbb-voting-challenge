class VoteCounter
  def self.increment(wall_id:, participant_id:)
    REDIS.multi do |redis|
      redis.incr(total_key(wall_id))
      redis.incr(participant_key(wall_id, participant_id))
    end
  end

  def self.total_wall_votes(wall_id:)
    REDIS.get(total_key(wall_id)).to_i
  end

  def self.total_for(wall_id:, participant_id:)
    REDIS.get(participant_key(wall_id, participant_id)).to_i
  end

  def self.total_key(wall_id)
    "walls:#{wall_id}:votes:total"
  end

  def self.participant_key(wall_id, participant_id)
    "walls:#{wall_id}:participants:#{participant_id}:votes"
  end
end