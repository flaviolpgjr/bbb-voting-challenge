class VoteCounter
  def self.increment(wall_id:, participant_id:, voted_at: Time.current)
    hour = normalize_hour(voted_at)

    REDIS.multi do |redis|
      redis.incr(total_key(wall_id))
      redis.incr(participant_key(wall_id, participant_id))
      redis.incr(hour_total_key(wall_id, hour))
      redis.incr(hour_participant_key(wall_id, hour, participant_id))
      redis.sadd(hours_key(wall_id), hour)
    end
  end

  def self.total_wall_votes(wall_id:)
    REDIS.get(total_key(wall_id)).to_i
  end

  def self.total_for(wall_id:, participant_id:)
    REDIS.get(participant_key(wall_id, participant_id)).to_i
  end

  def self.hourly_totals(wall_id:, participants:)
    hours = REDIS.smembers(hours_key(wall_id)).sort

    hours.map do |hour|
      {
        hour: hour,
        total_votes: REDIS.get(hour_total_key(wall_id, hour)).to_i,
        participants: participants.map do |participant|
          {
            id: participant.id,
            name: participant.name,
            votes: REDIS.get(hour_participant_key(wall_id, hour, participant.id)).to_i
          }
        end
      }
    end
  end

  def self.total_key(wall_id)
    "walls:#{wall_id}:votes:total"
  end

  def self.participant_key(wall_id, participant_id)
    "walls:#{wall_id}:participants:#{participant_id}:votes"
  end

  def self.hours_key(wall_id)
    "walls:#{wall_id}:hours"
  end

  def self.hour_total_key(wall_id, hour)
    "walls:#{wall_id}:hours:#{hour}:votes:total"
  end

  def self.hour_participant_key(wall_id, hour, participant_id)
    "walls:#{wall_id}:hours:#{hour}:participants:#{participant_id}:votes"
  end

  def self.normalize_hour(time)
    time.to_time.utc.beginning_of_hour.iso8601
  end
end