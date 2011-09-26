class CreatePlans < ActiveRecord::Migration
  def self.up
    create_table :plans do |t|
      t.string :name
      t.float :price
      t.integer :num_of_tweet_per_day
      t.integer :num_of_tweet_in_buffer
      t.integer :num_of_tweet_account
      t.boolean :free_browser_ext

      t.timestamps
    end
  end

  def self.down
    drop_table :plans
  end
end
