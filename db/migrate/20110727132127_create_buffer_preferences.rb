class CreateBufferPreferences < ActiveRecord::Migration
  def self.up
    create_table :buffer_preferences do |t|
      t.integer   :user_id
      t.integer   :twitter_user_id
      t.datetime  :today
      t.integer   :tweets_remaining
      t.string    :name, :limit => 64
      t.timestamps
    end
  end

  def self.down
    drop_table :buffer_preferences
  end
end
