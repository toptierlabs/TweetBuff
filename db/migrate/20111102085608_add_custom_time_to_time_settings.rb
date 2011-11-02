class AddCustomTimeToTimeSettings < ActiveRecord::Migration
  def self.up
    add_column :time_settings, :custom_time, :datetime
  end

  def self.down
    remove_column :time_settings, :custom_time, :datetime
  end
end
