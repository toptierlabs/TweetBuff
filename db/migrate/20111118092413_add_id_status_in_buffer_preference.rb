class AddIdStatusInBufferPreference < ActiveRecord::Migration
  def self.up
    add_column :buffer_preferences, :id_status, :integer
  end

  def self.down
    remove_column :buffer_preferences, :id_status, :integer
  end
end
