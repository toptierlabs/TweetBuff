class CreateBufferPreferences < ActiveRecord::Migration
  def self.up
    create_table :buffer_preferences do |t|
      t.integer   :twitter_user_id
      t.integer   :interval_duration
      t.integer   :intervals_per_diem
      t.datetime  :last_interval

      t.timestamps
    end
  end

  def self.down
    drop_table :buffer_preferences
  end
end
