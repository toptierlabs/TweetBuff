class AddCategoryNameToSuggestion < ActiveRecord::Migration
  def self.up
    add_column :suggestions, :category_name, :string
  end

  def self.down
    remove_column :suggestions, :category_name, :string
  end
end
