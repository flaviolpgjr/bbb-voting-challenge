require "rails_helper"

RSpec.describe VoteService do
  describe "#call" do
    let(:request) do
      instance_double(
        ActionDispatch::Request,
        remote_ip: "127.0.0.1",
        user_agent: "RSpec"
      )
    end

    before do
      Vote.delete_all
      WallParticipant.delete_all
      Wall.delete_all
      Participant.delete_all

      allow(VoteCounter).to receive(:increment)
      allow(VotePersistenceJob).to receive(:perform_later)
    end

    context "when vote is valid" do
      let(:wall) do
        Wall.create!(
          name: "Paredão 1",
          starts_at: 1.hour.ago,
          ends_at: 1.day.from_now,
          active: true
        )
      end

      let(:participant) { Participant.create!(name: "João") }

      before do
        WallParticipant.create!(wall: wall, participant: participant)
      end

      it "accepts the vote and triggers async processing" do
        result = described_class.new(
          participant_id: participant.id,
          request: request
        ).call

        expect(result.status).to eq(:accepted)
        expect(result.payload[:success]).to be true

        expect(VoteCounter).to have_received(:increment).with(
          wall_id: wall.id,
          participant_id: participant.id,
          voted_at: kind_of(String)
        )

        expect(VotePersistenceJob).to have_received(:perform_later).with(
          hash_including(
            wall_id: wall.id,
            participant_id: participant.id,
            ip_address: "127.0.0.1",
            user_agent: "RSpec"
          )
        )
      end
    end

    context "when there is no active wall" do
      let(:participant) { Participant.create!(name: "João") }

      it "returns not found" do
        result = described_class.new(
          participant_id: participant.id,
          request: request
        ).call

        expect(result.status).to eq(:not_found)
        expect(result.payload[:error]).to eq("No active wall found")
        expect(VoteCounter).not_to have_received(:increment)
        expect(VotePersistenceJob).not_to have_received(:perform_later)
      end
    end

    context "when participant does not exist" do
      before do
        Wall.create!(
          name: "Paredão 1",
          starts_at: 1.hour.ago,
          ends_at: 1.day.from_now,
          active: true
        )
      end

      it "returns not found" do
        result = described_class.new(
          participant_id: 999,
          request: request
        ).call

        expect(result.status).to eq(:not_found)
        expect(result.payload[:error]).to eq("Participant not found")
        expect(VoteCounter).not_to have_received(:increment)
        expect(VotePersistenceJob).not_to have_received(:perform_later)
      end
    end

    context "when participant does not belong to active wall" do
      let(:wall) do
        Wall.create!(
          name: "Paredão 1",
          starts_at: 1.hour.ago,
          ends_at: 1.day.from_now,
          active: true
        )
      end

      let(:participant) { Participant.create!(name: "João") }

      before do
        wall
        participant
      end

      it "returns unprocessable entity" do
        result = described_class.new(
          participant_id: participant.id,
          request: request
        ).call

        expect(result.status).to eq(:unprocessable_entity)
        expect(result.payload[:error]).to eq("Participant does not belong to active wall")
        expect(VoteCounter).not_to have_received(:increment)
        expect(VotePersistenceJob).not_to have_received(:perform_later)
      end
    end
  end
end