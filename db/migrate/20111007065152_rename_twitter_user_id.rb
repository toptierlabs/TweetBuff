class RenameTwitterUserId < ActiveRecord::Migration
  def self.up
    rename_column :tweet_histories, :twitter_user_id, :user_id
  end

  def self.down
    rename_column :tweet_histories, :user_id, :twitter_user_id
  end
end
