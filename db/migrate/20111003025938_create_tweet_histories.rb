class CreateTweetHistories < ActiveRecord::Migration
  def self.up
    create_table :tweet_histories do |t|
      t.integer :twitter_user_id
      t.datetime :last_tweet
      t.integer :tweet_remain

      t.timestamps
    end
  end

  def self.down
    drop_table :tweet_histories
  end
end
