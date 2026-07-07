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

      let(:hourly_totals) do
        [
          {
            hour: "2026-07-07T18:00:00Z",
            total_votes: 10,
            participants: [
              { id: participant_one.id, name: "João", votes: 7 },
              { id: participant_two.id, name: "Maria", votes: 3 }
            ]
          }
        ]
      end

      before do
        WallParticipant.create!(wall: wall, participant: participant_one)
        WallParticipant.create!(wall: wall, participant: participant_two)

        allow(VoteCounter).to receive(:total_wall_votes)
          .with(wall_id: wall.id)
          .and_return(10)

        allow(VoteCounter).to receive(:total_for)
          .with(wall_id: wall.id, participant_id: participant_one.id)
          .and_return(7)

        allow(VoteCounter).to receive(:total_for)
          .with(wall_id: wall.id, participant_id: participant_two.id)
          .and_return(3)

        allow(VoteCounter).to receive(:hourly_totals)
          .with(wall_id: wall.id, participants: [participant_one, participant_two])
          .and_return(hourly_totals)
      end

      it "returns total votes, participant results and hourly totals" do
        result = described_class.new.call

        expect(result.status).to eq(:ok)

        expect(result.payload).to eq(
          {
            wall: {
              id: wall.id,
              name: "Paredão 1"
            },
            total_votes: 10,
            participants: [
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
            ],
            hourly: hourly_totals
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