# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111003095246) do

  create_table "active_admin_comments", :force => true do |t|
    t.integer  "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "buffer_preferences", :force => true do |t|
    t.integer  "user_id"
    t.integer  "twitter_user_id"
    t.integer  "tweet_mode",       :limit => 1
    t.datetime "today"
    t.integer  "tweets_remaining"
    t.string   "name",             :limit => 64
    t.string   "timezone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink"
  end

  add_index "buffer_preferences", ["twitter_user_id"], :name => "index_buffer_preferences_on_twitter_user_id"

  create_table "carts", :force => true do |t|
    t.datetime "purchased_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "line_items", :force => true do |t|
    t.integer  "plan_id"
    t.integer  "cart_id"
    t.integer  "qty"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_notifications", :force => true do |t|
    t.text     "params"
    t.integer  "cart_id"
    t.string   "status"
    t.string   "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", :force => true do |t|
    t.string   "name"
    t.float    "price"
    t.integer  "num_of_tweet_per_day"
    t.integer  "num_of_tweet_in_buffer"
    t.integer  "num_of_tweet_account"
    t.boolean  "free_browser_ext"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "num_of_team_member_per_account"
  end

  create_table "plans_timeframes", :id => false, :force => true do |t|
    t.integer "plan_id"
    t.integer "timeframe_id"
  end

  create_table "preferences", :force => true do |t|
    t.integer  "user_id"
    t.string   "key"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subcriptions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "plan_id"
    t.date     "expire"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cart_id"
    t.boolean  "active",     :default => false
  end

  create_table "time_definitions", :force => true do |t|
    t.boolean  "interval",                          :default => true
    t.integer  "buffer_preference_id"
    t.integer  "day_of_week",          :limit => 1, :default => 0
    t.integer  "start_hour",           :limit => 1, :default => 0
    t.integer  "start_minute",         :limit => 1, :default => 0
    t.integer  "interval_length",                   :default => 3600
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "time_definitions", ["buffer_preference_id"], :name => "index_time_definitions_on_buffer_preference_id"
  add_index "time_definitions", ["day_of_week", "interval"], :name => "index_time_definitions_on_day_of_week_and_interval"
  add_index "time_definitions", ["day_of_week", "start_hour", "start_minute"], :name => "index_time_defs_dow_hour_min"
  add_index "time_definitions", ["interval", "interval_length"], :name => "index_time_definitions_on_interval_and_interval_length"
  add_index "time_definitions", ["interval", "start_minute"], :name => "index_time_definitions_on_interval_and_start_minute"
  add_index "time_definitions", ["start_hour", "start_minute"], :name => "index_time_definitions_on_start_hour_and_start_minute"

  create_table "timeframes", :force => true do |t|
    t.string   "name"
    t.integer  "value"
    t.string   "unit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tweet_histories", :force => true do |t|
    t.integer  "twitter_user_id"
    t.datetime "last_tweet"
    t.integer  "tweet_remain"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "buffer_id"
  end

  create_table "tweet_intervals", :force => true do |t|
    t.integer  "user_id"
    t.integer  "twitter_user_id"
    t.integer  "timeframe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "other_interval"
  end

  create_table "tweets", :force => true do |t|
    t.integer  "twitter_user_id"
    t.integer  "buffer_preference_id"
    t.integer  "position"
    t.datetime "sent_at"
    t.string   "title"
    t.string   "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "twitter_users", :force => true do |t|
    t.boolean "protected"
    t.integer "user_id"
    t.integer "friends_count"
    t.integer "statuses_count"
    t.integer "followers_count"
    t.integer "utc_offset"
    t.string  "twitter_id"
    t.string  "login"
    t.string  "access_token"
    t.string  "access_secret"
    t.string  "remember_token"
    t.string  "name"
    t.string  "profile_image_url"
    t.string  "url"
    t.string  "time_zone"
    t.string  "permalink"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
