class AddOtherIntervalToTweetInterval < ActiveRecord::Migration
  def self.up
    add_column :tweet_intervals, :other_interval, :string
  end

  def self.down
    remove_column :tweet_intervals, :other_interval
  end
end
