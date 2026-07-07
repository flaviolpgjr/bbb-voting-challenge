require "rails_helper"

RSpec.describe VoteCounter do
  describe ".increment" do
    let(:wall_id) { 1 }
    let(:participant_id) { 10 }
    let(:voted_at) { Time.zone.parse("2026-07-07 18:35:00") }
    let(:hour) { "2026-07-07T18:00:00Z" }

    before do
      REDIS.flushdb
    end

    after do
      REDIS.flushdb
    end

    it "increments total, participant and hourly counters" do
      described_class.increment(
        wall_id: wall_id,
        participant_id: participant_id,
        voted_at: voted_at
      )

      expect(REDIS.get("walls:1:votes:total").to_i).to eq(1)
      expect(REDIS.get("walls:1:participants:10:votes").to_i).to eq(1)
      expect(REDIS.get("walls:1:hours:2026-07-07T18:00:00Z:votes:total").to_i).to eq(1)
      expect(REDIS.get("walls:1:hours:2026-07-07T18:00:00Z:participants:10:votes").to_i).to eq(1)
      expect(REDIS.smembers("walls:1:hours")).to include(hour)
    end
  end

  describe ".hourly_totals" do
    let(:wall_id) { 1 }
    let(:participant_one) { instance_double(Participant, id: 10, name: "João") }
    let(:participant_two) { instance_double(Participant, id: 20, name: "Maria") }
    let(:participants) { [participant_one, participant_two] }

    before do
      REDIS.flushdb

      described_class.increment(
        wall_id: wall_id,
        participant_id: 10,
        voted_at: Time.zone.parse("2026-07-07 18:10:00")
      )

      described_class.increment(
        wall_id: wall_id,
        participant_id: 20,
        voted_at: Time.zone.parse("2026-07-07 19:15:00")
      )
    end

    after do
      REDIS.flushdb
    end

    it "returns hourly totals grouped by hour" do
      result = described_class.hourly_totals(
        wall_id: wall_id,
        participants: participants
      )

      expect(result).to eq(
        [
          {
            hour: "2026-07-07T18:00:00Z",
            total_votes: 1,
            participants: [
              { id: 10, name: "João", votes: 1 },
              { id: 20, name: "Maria", votes: 0 }
            ]
          },
          {
            hour: "2026-07-07T19:00:00Z",
            total_votes: 1,
            participants: [
              { id: 10, name: "João", votes: 0 },
              { id: 20, name: "Maria", votes: 1 }
            ]
          }
        ]
      )
    end
  end
end