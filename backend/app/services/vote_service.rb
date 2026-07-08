class VoteService
  def initialize(participant_id:, request:)
    @participant_id = participant_id
    @request = request
  end

  def call
    VOTE_REQUESTS_COUNTER.increment

    return failure(:not_found, "No active wall found") unless active_wall
    return failure(:not_found, "Participant not found") unless participant
    return failure(:unprocessable_entity, "Participant does not belong to active wall") unless active_wall.has_participant?(participant)

    payload = vote_payload

    log_vote_payload_created(payload)

    VoteCounter.increment(
      wall_id: active_wall.id,
      participant_id: participant.id,
      voted_at: payload[:voted_at]
    )

    VotePersistenceJob.perform_later(payload)

    log_vote_accepted(payload)

    success(payload)
  end

  private

  attr_reader :participant_id, :request

  def active_wall
    @active_wall ||= Wall.active.first
  end

  def participant
    @participant ||= Participant.find_by(id: participant_id)
  end

  def vote_payload
    {
      wall_id: active_wall.id,
      participant_id: participant.id,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      voted_at: Time.current.iso8601
    }
  end

  def success(payload)
    VOTES_ACCEPTED_COUNTER.increment

    ServiceResult.new(
      status: :accepted,
      payload: {
        success: true,
        message: "Vote accepted for processing",
        vote: {
          wall_id: payload[:wall_id],
          participant_id: payload[:participant_id]
        }
      }
    )
  end

  def failure(status, message)
    VOTES_REJECTED_COUNTER.increment
    log_vote_rejected(status, message)

    ServiceResult.new(
      status: status,
      payload: {
        success: false,
        error: message
      }
    )
  end

  def log_vote_payload_created(payload)
    Rails.logger.debug(
      event: "vote.payload_created",
      wall_id: payload[:wall_id],
      participant_id: payload[:participant_id],
      ip_address: payload[:ip_address]
    )
  end

  def log_vote_accepted(payload)
    Rails.logger.info(
      event: "vote.accepted",
      wall_id: payload[:wall_id],
      participant_id: payload[:participant_id],
      ip_address: payload[:ip_address]
    )
  end

  def log_vote_rejected(status, message)
    Rails.logger.warn(
      event: "vote.rejected",
      status: status,
      reason: message,
      participant_id: participant_id,
      ip_address: request.remote_ip
    )
  end
end