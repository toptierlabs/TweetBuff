class CreateTimeDefinitions < ActiveRecord::Migration
  def self.up
    create_table :time_definitions do |t|
      t.boolean :interval,        :default => true
      t.integer :time_index_id
      t.integer :buffer_preference_id
      t.integer :day_of_week,     :default => 0, :limit => 1  # (0..6)  < 127
      t.integer :start_hour,      :default => 0, :limit => 1  # (0..24) < 127
      t.integer :start_minute,    :default => 0, :limit => 1  # (0..59) < 127
      t.integer :interval_length, :default => 3600            # 1 hour
      t.timestamps
    end

    add_index :time_definitions, :time_index_id
    add_index :time_definitions, :buffer_preference_id
    add_index :time_definitions, [:day_of_week, :start_hour, :start_minute]
    add_index :time_definitions, [:day_of_week, :interval]
    add_index :time_definitions, [:start_hour, :start_minute]
    add_index :time_definitions, [:interval, :interval_length]
    add_index :time_definitions, [:interval, :start_minute]
  end

  def self.down
    drop_table :time_definitions
    remove_index :time_definitions, :column => :time_index_id
    remove_index :time_definitions, :column => :buffer_preference_id
    remove_index :time_definitions, :column => [:day_of_week, :start_hour, :start_minute]
    remove_index :time_definitions, :column => [:day_of_week, :interval]
    remove_index :time_definitions, :column => [:start_hour, :start_minute]
    remove_index :time_definitions, :column => [:interval, :interval_length]
    remove_index :time_definitions, :column => [:interval, :start_minute]
  end
end
