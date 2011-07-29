class CreateTimeIndices < ActiveRecord::Migration
  def self.up
    create_table :time_indices do |t|
      t.integer :twitter_user_id
      t.integer :buffer_preference_id
      t.integer :tweet_mode, :limit => 1
      t.string  :timezone
      t.timestamps
    end

    add_index :time_indices, [:buffer_preference_id, :twitter_user_id]

  end

  def self.down
    drop_table :time_indices
    remove_index :time_indices, :column => [:buffer_id, :twitter_user_id]
  end
end
