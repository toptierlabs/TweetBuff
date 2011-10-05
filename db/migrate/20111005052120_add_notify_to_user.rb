class AddNotifyToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :notify, :boolean, :default => false
  end

  def self.down
    remove_column :users, :notify
  end
end
