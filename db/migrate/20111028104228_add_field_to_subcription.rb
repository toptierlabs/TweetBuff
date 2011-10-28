class AddFieldToSubcription < ActiveRecord::Migration
  def self.up
    add_column :subcriptions, :day_time_tweet, :date
    add_column :subcriptions, :tweet_per_day, :integer
  end

  def self.down
    remove_column :subcriptions, :day_time_tweet, :date
    remove_column :subcriptions, :tweet_per_day, :integer
  end
end
