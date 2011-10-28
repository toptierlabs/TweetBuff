class CreateTableDays < ActiveRecord::Migration
  def self.up
    create_table :days do |t|
      t.string :day_name
    end
  end

  def self.down
    drop_table :days
  end
end
