class CreateBufferPreferences < ActiveRecord::Migration
  def self.up
    create_table :buffer_preferences do |t|
      t.integer   :user_id
      t.integer   :twitter_user_id
      t.integer   :tweet_mode, :limit => 1
      t.datetime  :today
      t.integer   :tweets_remaining
      t.string    :name, :limit => 64
      t.string    :timezone
      t.timestamps
    end

    add_index :buffer_preferences, [:twitter_user_id]

  end

  def self.down
    drop_table :buffer_preferences
    remove_index :buffer_preferences, :column => [:twitter_user_id]
  end
end
