class CreateTwitterUsers < ActiveRecord::Migration
  def self.up
    create_table :twitter_users do |t|
      t.boolean :protected
      t.boolean :profile_background_tiled
      t.integer :user_id
      t.integer :friends_count
      t.integer :statuses_count
      t.integer :followers_count
      t.integer :favourites_count
      t.integer :utc_offset      
      t.datetime :remember_token_expires_at
      t.string :twitter_id
      t.string :login
      t.string :access_token
      t.string :access_secret
      t.string :remember_token
      t.string :name
      t.string :location
      t.string :description
      t.string :profile_image_url
      t.string :url
      t.string :profile_background_color
      t.string :profile_sidebar_fill_color
      t.string :profile_link_color
      t.string :profile_sidebar_border_color
      t.string :profile_text_color
      t.string :profile_background_image_url  
      t.string :time_zone
    end
  end

  def self.down
    drop_table :twitter_users
  end
end
