class CreateTimezones < ActiveRecord::Migration
  def self.up
    create_table :timezones do |t|
      t.string :timezone

      t.timestamps
    end
  end

  def self.down
    drop_table :timezones
  end
end
