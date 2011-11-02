class CreateTimeSettings < ActiveRecord::Migration
  def self.up
    create_table :time_settings do |t|
      t.string :day_of_week
      t.integer :time_setting_type
      t.integer :post_per_day
      t.datetime :start_time
      t.integer :twitter_user_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :time_settings
  end
end
