class AddAddedTimeToBufferPreference < ActiveRecord::Migration
  def self.up
    add_column :buffer_preferences, :added_time, :integer, :default => 0
  end

  def self.down
    remove_column :buffer_preferences, :added_time
  end
end
