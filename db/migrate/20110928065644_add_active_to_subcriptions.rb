class AddActiveToSubcriptions < ActiveRecord::Migration
  def self.up
    add_column :subcriptions, :active, :boolean, :default => false
  end

  def self.down
    remove_column :subcriptions, :active
  end
end
