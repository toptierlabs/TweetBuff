class CreateTweetTimes < ActiveRecord::Migration
  def self.up
    create_table :tweet_times do |t|
      t.integer :buffer_preference_id
      t.time    :tweet_at
    end
  end

  def self.down
    drop_table :tweet_times
  end
end
