# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Clear existing data
if defined?(REDIS)
  REDIS.flushdb
end
Vote.delete_all
WallParticipant.delete_all
Participant.delete_all
Wall.delete_all

# Participants
participant_1 = Participant.create!(
  name: "João"
)

participant_2 = Participant.create!(
  name: "Maria"
)

# Active wall
wall = Wall.create!(
  name: "Paredão 1",
  starts_at: Time.current,
  ends_at: 2.days.from_now,
  active: true
)

WallParticipant.create!(
  wall: wall,
  participant: participant_1
)

WallParticipant.create!(
  wall: wall,
  participant: participant_2
)

puts "Seed completed successfully!"
puts "Active wall: #{wall.name}"
puts "Participants:"
puts "- #{participant_1.name}"
puts "- #{participant_2.name}"