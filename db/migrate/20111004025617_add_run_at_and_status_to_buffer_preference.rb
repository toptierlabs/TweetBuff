class AddRunAtAndStatusToBufferPreference < ActiveRecord::Migration
  def self.up
    add_column :buffer_preferences, :run_at, :datetime
    add_column :buffer_preferences, :status, :string
  end

  def self.down
    remove_column :buffer_preferences, :status
    remove_column :buffer_preferences, :run_at
  end
end
