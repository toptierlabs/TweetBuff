Tweetbuffer::Application.routes.draw do
  
  #API Url
  #api session
  match "api/check_sign_in_session" => "api/sessions#check_sign_in_session"
  #api tweet
  match "api/twitter_account_list" => "api/twitter_users#twitter_account_list"
  match "api/post_to_twitter" => "api/twitter_users#post_to_twitter"
  match "api/send_to_buff" => "api/twitter_users#send_to_buff"
  match "add_account" => "dashboard#add_account", :as => :add_account

  resources :timezones

  resources :tweet_histories

  resources :tweet_intervals

  resources :timeframes

  get "/goodies" => "goodies#index"

  resources :subcriptions
  resources :payment_notifications

  match "paypall_callback" => "dashboard#paypall_callback", :as => :paypall_callback

  resources :plans do
    member do
      get "get_plan_clicked_when_signup"
    end
  end

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users

  root :to => 'Home#index'  

  scope "dashboard" do
    controller :dashboard do
      get   "" => :show, :as => :dashboard
      get   "settings/account" => :account, :as => :account_settings
      post  "settings/account/update" => :update, :as => :account_settings
      get   "settings/twitter" => :twitter, :as => :twitter_settings
    end
  end

  scope "twitter" do
    resources :bitly_apis do
      collection do
        post "save_detail" => :create_or_update
      end
    end
    
    controller :twitter_sessions do
      get   "authorize" => :new, :as => :twitter_authorize_account
      get   "callback" => :oauth_callback, :as => :twitter_callback
    end
    
    get "/" => "TwitterUsers#index", :as => :twitter_users
    get "/twitt_account/:twitter_name" => "TwitterUsers#index", :as => :twitter_user
    get "/tweet_to_twitter" => "TwitterUsers#tweet_to_twitter", :as => :tweet_to_twitter
    get "/twitter_account_list" => "TwitterUsers#twitter_account_list"
    get "/settings" => "TwitterUsers#settings", :as => :twitter_settings
    get "/settings/other_time_interval" => "TwitterUsers#other_time_interval", :as => :other_ti
    get "/settings/default_interval" => "TwitterUsers#default_interval", :as => :default_ti
    post "/settings/update_timezone" => "TwitterUsers#update_timezone", :as => :update_timezone
    post "/settings/update_notify" => "TwitterUsers#update_notify", :as => :update_notify
    post "/save_settings" => "TwitterUsers#save_settings"

    scope ":twitter_name" do
      controller :buffer_preferences do
        get     "buffers"     => :index,    :as => :twitter_user_buffer_preferences
        post    "buffers"     => :create,   :as => :twitter_user_buffer_preferences
        get     "buffers/new" => :new,      :as => :new_twitter_user_buffer_preference
      end

      scope ":buffer_name" do
        resources :tweets do
          collection do
            post :sort
          end
        end

        controller :buffer_preferences do
          get     "edit"  => :edit,             :as => :edit_twitter_user_buffer_preference
          get     "/"     => :show,             :as => :twitter_user_buffer_preference
          put     "/"     => :update,           :as => :twitter_user_buffer_preference
          delete  "/"     => :destroy,          :as => :twitter_user_buffer_preference
          get     "time"  => :new_tweet_time,   :as => :new_twitter_user_buffer_preference_tweet_time
        end

        post    "time" => "TimeDefinitions#create_time",  :as => :twitter_user_buffer_preference_tweet_time
        delete  "time" => "TimeDefinitions#destroy_time", :as => :twitter_user_buffer_preference_tweet_time
      end
    end
  end




end
