class ChangeFileSizeNameInBuffer < ActiveRecord::Migration
  def self.up
    change_column :buffer_preferences, :name, :string, :limit => 140
  end

  def self.down
  end
end
