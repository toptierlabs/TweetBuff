class AddIndexToForeignKeyFields < ActiveRecord::Migration
  def self.up
    add_index :bitly_apis, :user_id
    add_index :buffer_preferences, :user_id
    add_index :carts, :user_id
    add_index :line_items, [:plan_id, :cart_id]
    add_index :payment_notifications, [:cart_id, :transaction_id]
    add_index :plans_timeframes, [:plan_id, :timeframe_id]
    add_index :preferences, :user_id
    add_index :subscriptions, [:user_id, :plan_id, :cart_id]
    add_index :suggestions, [:category_id, :user_id, :twitter_user_id]
    add_index :time_settings, [:timeframe_id, :twitter_user_id, :user_id]
    add_index :tweets, [:twitter_user_id, :buffer_preference_id]
    add_index :tweet_histories, [:user_id, :buffer_id]
    add_index :tweet_intervals, [:user_id, :twitter_user_id, :timeframe_id]
    add_index :twitter_users, [:user_id, :twitter_id]
    add_index :users, :referal_id
  end
  
  def self.down
  end
end
