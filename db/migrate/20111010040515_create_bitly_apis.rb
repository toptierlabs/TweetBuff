class CreateBitlyApis < ActiveRecord::Migration
  def self.up
    create_table :bitly_apis do |t|
      t.integer :user_id
      t.string :bitly_name
      t.string :api_key

      t.timestamps
    end
  end

  def self.down
    drop_table :bitly_apis
  end
end
