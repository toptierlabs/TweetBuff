class ChangeTypeDataForIdStatusInBufferPreference < ActiveRecord::Migration
  def self.up
    change_column :buffer_preferences, :id_status, :string
  end

  def self.down
  end
end
