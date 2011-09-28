class AddCartIdToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subcriptions, :cart_id, :integer
  end

  def self.down
    remove_column :subcriptions, :cart_id
  end
end
