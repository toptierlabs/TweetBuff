class AddReferalIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :referal_id, :integer
  end

  def self.down
    remover_column :users, :referal_id, :integer
  end
end
