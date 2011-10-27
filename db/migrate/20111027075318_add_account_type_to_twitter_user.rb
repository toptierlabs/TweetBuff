class AddAccountTypeToTwitterUser < ActiveRecord::Migration
  def self.up
    add_column :twitter_users, :account_type, :string
  end

  def self.down
    remove_column :twitter_users, :account_type, :string
  end
end
