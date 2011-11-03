class AddTimePeriodToTimeSetting < ActiveRecord::Migration
  def self.up
    add_column :time_settings, :time_period, :string
  end

  def self.down
    remove_column :time_settings, :time_period, :string
  end
end
