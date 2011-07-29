class CreateTweets < ActiveRecord::Migration
  def self.up
    create_table :tweets do |t|
      t.integer   :user_id
      t.integer   :buffer_preference_id
      t.integer   :position
      t.datetime  :sent_at
      t.string    :title
      t.string    :body

      t.timestamps
    end
  end

  def self.down
    drop_table :tweets
  end
end
