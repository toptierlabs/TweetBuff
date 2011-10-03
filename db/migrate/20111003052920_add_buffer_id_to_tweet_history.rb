class AddBufferIdToTweetHistory < ActiveRecord::Migration
  def self.up
    add_column :tweet_histories, :buffer_id, :integer
  end

  def self.down
    remove_column :tweet_histories, :buffer_id
  end
end
