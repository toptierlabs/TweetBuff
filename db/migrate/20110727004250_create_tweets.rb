class CreateTweets < ActiveRecord::Migration
  def self.up
    create_table :tweets do |t|
      t.integer   :position
      t.integer   :user_id
      t.datetime  :send_at
      t.string    :title
      t.string    :body



      t.timestamps
    end
  end

  def self.down
    drop_table :tweets
  end
end
