class AddUserIdAndTwitterUserIdToSuggestion < ActiveRecord::Migration
  def self.up
    add_column :suggestions, :user_id, :integer
    add_column :suggestions, :twitter_user_id, :integer
  end

  def self.down
    remove_column :suggestions, :user_id, :integer
    remove_column :suggestions, :twitter_user_id, :integer
  end
end
