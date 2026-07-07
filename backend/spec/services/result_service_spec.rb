require "rails_helper"

RSpec.describe ResultService do
  describe "#call" do
    before do
      Vote.delete_all
      WallParticipant.delete_all
      Wall.delete_all
      Participant.delete_all
    end

    context "when there is an active wall" do
      let(:wall) do
        Wall.create!(
          name: "Paredão 1",
          starts_at: 1.hour.ago,
          ends_at: 1.day.from_now,
          active: true
        )
      end

      let(:participant_one) { Participant.create!(name: "João") }
      let(:participant_two) { Participant.create!(name: "Maria") }

      before do
        WallParticipant.create!(wall: wall, participant: participant_one)
        WallParticipant.create!(wall: wall, participant: participant_two)

        allow(VoteCounter).to receive(:total_wall_votes).with(wall_id: wall.id).and_return(10)
        allow(VoteCounter).to receive(:total_for).with(wall_id: wall.id, participant_id: participant_one.id).and_return(7)
        allow(VoteCounter).to receive(:total_for).with(wall_id: wall.id, participant_id: participant_two.id).and_return(3)
      end

      it "returns vote totals and percentages" do
        result = described_class.new.call

        expect(result.status).to eq(:ok)
        expect(result.payload[:total_votes]).to eq(10)

        expect(result.payload[:participants]).to contain_exactly(
          {
            id: participant_one.id,
            name: "João",
            votes: 7,
            percentage: 70.0
          },
          {
            id: participant_two.id,
            name: "Maria",
            votes: 3,
            percentage: 30.0
          }
        )
      end
    end

    context "when there is no active wall" do
      it "returns not found" do
        result = described_class.new.call

        expect(result.status).to eq(:not_found)
        expect(result.payload[:success]).to be false
        expect(result.payload[:error]).to eq("No active wall found")
      end
    end
  end
end