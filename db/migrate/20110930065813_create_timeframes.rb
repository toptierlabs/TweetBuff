class CreateTimeframes < ActiveRecord::Migration
  def self.up
    create_table :timeframes do |t|
      t.string :name
      t.integer :value
      t.string :unit

      t.timestamps
    end
  end

  def self.down
    drop_table :timeframes
  end
end
