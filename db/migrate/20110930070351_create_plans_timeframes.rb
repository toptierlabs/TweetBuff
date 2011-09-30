class CreatePlansTimeframes < ActiveRecord::Migration
  def self.up
    create_table :plans_timeframes, :id => false do |t|
      t.integer :plan_id
      t.integer :timeframe_id
    end
  end

  def self.down
  end
end
