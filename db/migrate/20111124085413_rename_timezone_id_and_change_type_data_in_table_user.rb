class RenameTimezoneIdAndChangeTypeDataInTableUser < ActiveRecord::Migration
  def self.up
    rename_column(:users, :timezone_id, :timezone)
    change_column :users, :timezone, :string
  end

  def self.down
  end
end
