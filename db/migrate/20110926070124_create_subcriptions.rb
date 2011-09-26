class CreateSubcriptions < ActiveRecord::Migration
  def self.up
    create_table :subcriptions do |t|
      t.integer :user_id
      t.integer :plan_id
      t.datetime :expire

      t.timestamps
    end
  end

  def self.down
    drop_table :subcriptions
  end
end
