class AddCategoryNameToSuggestion < ActiveRecord::Migration
  def self.up
    add_column :suggestions, :category_id, :integer
  end

  def self.down
    remove_column :suggestions, :category_id, :integer
  end
end
