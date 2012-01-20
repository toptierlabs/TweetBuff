Tweetbuffer::Application.routes.draw do
  #API Url
  #api session
  match "api/check_sign_in_session" => "api/sessions#check_sign_in_session"
  #api tweet
  match "api/twitter_account_list" => "api/twitter_users#twitter_account_list"
  match "api/post_to_twitter" => "api/twitter_users#post_to_twitter"
  match "api/send_to_buff" => "api/twitter_users#send_to_buff"
  #  match "add_account" => "dashboard#add_account", :as => :add_account
  match 'twitter_users/delete_buffer/:id' => 'twitter_users#delete_buffer', :as => :delete_buffer, :via => :get
  match 'twitter_users/edit_buffer/:id' => 'twitter_users#edit_buffer', :as => :edit_buffer, :via => :get
  match "twitter_users/:id/update_buffer" => "twitter_users#update_buffer", :as => :update_buffer
  match "twitter_users/add_an_account" => "twitter_users#add_an_account", :as => :add_an_account
  match "invite_team_member" => 'TwitterUsers#invite_team_member', :via => :post, :as => :invite_team_member

  post "/save_settings" => "twitter_users#save_settings", :as => :save_settings

  resources :timezones

  resources :tweet_histories

  resources :tweet_intervals

  resources :timeframes
  
  resources :suggestions

  get "/goodies" => "goodies#index"
  get "suggestions/tweet_suggestion/:twitter_name" => "suggestions#tweet_suggestion"
  
  match "setting_suggestion" => "Suggestions#setting_suggestion", :as => :setting_suggestion, :via => :get
  match "get_category/:id" => "Suggestions#get_category", :as => :get_category, :via => :post
  
  get "/update_setting_time" => "TwitterUsers#update_setting_time"

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

  devise_scope :admin_user do
    get '/admin/logout', :to => 'active_admin/devise/sessions#destroy'
  end

  devise_for :users, :controllers => {:registrations => "devise/registration", :sessions => "devise/session", :passwords => "devise/password"}
 
  root :to => 'Home#index'  

  get "/settings/account" => "dashboard#account", :as => :account_settings
  post "/settings/account/update" => "dashboard#update", :as => :account_settings
  
  scope "dashboard" do
    get "/facebook/:twitter_name" => "TwitterUsers#index", :as => :facebook_user
    get "/twitter/:twitter_name" => "TwitterUsers#index", :as => :twitter_user
    
    controller :dashboard do
      get   "" => :show, :as => :dashboard
      get   "settings/twitter" => :twitter, :as => :twitter_settings
    end
  end
  
  get "/settings/twitter/:twitter_name" => "TwitterUsers#settings", :as => :twitter_settings
  get "/settings/facebook/:twitter_name" => "TwitterUsers#settings", :as => :facebook_settings
  
  scope "facebook" do
    controller :facebook_sessions do
      get   "authorize" => :new, :as => :facebook_authorize_account
      get   "callback" => :oauth_callback, :as => :facebook_callback
    end
    #    get "/settings" => "TwitterUsers#settings", :as => :facebook_settings
  end
   
  match "twitter/bitly_apis/delete/:id" => "bitly_apis#delete_bitly", :as => :delete_bitly, :via => :get
  
  scope "twitter" do
    #    match "add_account" => "dashboard#add_account", :as => :add_account
    get "/new" => "dashboard#add_account", :as => :add_account
    
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
    
    get "/performance/:twitter_name" => "TwitterUsers#performance", :as => :twitter_user_performance
    get "/analytic/:twitter_name" => "TwitterUsers#analytic", :as => :twitter_user_analytic
    
    get "/tweet_to_twitter" => "TwitterUsers#tweet_to_twitter", :as => :tweet_to_twitter
    get "/tweet_from_buffer/:id" => "TwitterUsers#tweet_from_buffer", :as => :tweet_from_buffer
    
    get "/twitter_account_list" => "TwitterUsers#twitter_account_list"
    
    #    get "/settings" => "TwitterUsers#settings", :as => :twitter_settings
    
    get "/settings/other_time_interval" => "TwitterUsers#other_time_interval", :as => :other_ti
    get "/settings/default_interval" => "TwitterUsers#default_interval", :as => :default_ti
    post "/settings/update_timezone" => "TwitterUsers#update_timezone", :as => :update_timezone
    post "/settings/update_notify" => "TwitterUsers#update_notify", :as => :update_notify

    scope ":twitter_name" do
      controller :buffer_preferences do
        get     "buffers"     => :index,    :as => :twitter_user_buffer_preferences
        post    "buffers"     => :create,   :as => :twitter_user_buffer_preferences
        get     "buffers/new" => :new,      :as => :new_twitter_user_buffer_preference
      end
      
      controller :suggestions do
        post    "suggestions"     => :create,   :as => :twitter_user_suggestions
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
