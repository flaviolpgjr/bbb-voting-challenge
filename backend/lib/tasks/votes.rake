namespace :votes do
  desc "Rebuild Redis vote counters from persisted votes"
  task rebuild_counters: :environment do
    puts "Rebuilding vote counters..."

    REDIS.flushdb

    Vote.find_each do |vote|
      VoteCounter.increment(
        wall_id: vote.wall_id,
        participant_id: vote.participant_id,
        voted_at: vote.created_at
      )
    end

    puts "Done. Rebuilt #{Vote.count} votes."
  end
end