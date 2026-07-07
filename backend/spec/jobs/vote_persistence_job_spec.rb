require "rails_helper"

RSpec.describe VotePersistenceJob, type: :job do
  describe "#perform" do
    let(:wall) do
      Wall.create!(
        name: "Paredão 1",
        starts_at: 1.hour.ago,
        ends_at: 1.day.from_now,
        active: true
      )
    end

    let(:participant) { Participant.create!(name: "João") }

    let(:payload) do
      {
        wall_id: wall.id,
        participant_id: participant.id,
        ip_address: "127.0.0.1",
        user_agent: "RSpec",
        voted_at: Time.current.iso8601
      }
    end

    it "persists the vote" do
      expect {
        described_class.perform_now(payload)
      }.to change(Vote, :count).by(1)

      vote = Vote.last

      expect(vote.wall_id).to eq(wall.id)
      expect(vote.participant_id).to eq(participant.id)
      expect(vote.ip_address).to eq("127.0.0.1")
      expect(vote.user_agent).to eq("RSpec")
    end
  end
end