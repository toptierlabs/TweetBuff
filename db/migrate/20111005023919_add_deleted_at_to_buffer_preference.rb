class AddDeletedAtToBufferPreference < ActiveRecord::Migration
  def self.up
    add_column :buffer_preferences, :deleted_at, :datetime
  end

  def self.down
    remove_column :buffer_preferences, :deleted_at
  end
end
