class CreateTweetIntervals < ActiveRecord::Migration
  def self.up
    create_table :tweet_intervals do |t|
      t.integer :user_id
      t.integer :twitter_user_id
      t.integer :timeframe_id

      t.timestamps
    end
  end

  def self.down
    drop_table :tweet_intervals
  end
end
