class CreateTwitterUsers < ActiveRecord::Migration
  def self.up
    create_table :twitter_users do |t|
      t.boolean :protected
      t.integer :user_id
      t.integer :friends_count
      t.integer :statuses_count
      t.integer :followers_count
      t.integer :utc_offset
      t.string :twitter_id
      t.string :login
      t.string :access_token
      t.string :access_secret
      t.string :remember_token
      t.string :name
      t.string :profile_image_url
      t.string :url
      t.string :time_zone
    end
  end

  def self.down
    drop_table :twitter_users
  end
end
