Tweetbuffer::Application.routes.draw do
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
    controller :twitter_sessions do
      get   "authorize" => :new, :as => :twitter_authorize_account
      get   "callback" => :oauth_callback, :as => :twitter_callback
    end

    get     "/"               => "TwitterUsers#index",         :as => :twitter_users

    scope ":twitter_name" do
      controller :buffer_preferences do
        get     "buffers"     => :index,    :as => :twitter_user_buffer_preferences
        post    "buffers"     => :create,   :as => :twitter_user_buffer_preferences
        get     "buffers/new" => :new,      :as => :new_twitter_user_buffer_preference
      end

      scope ":buffer_name" do
        controller :buffer_preferences do
          get     "edit"  => :edit,             :as => :edit_twitter_user_buffer_preference
          get     "/"     => :show,             :as => :twitter_user_buffer_preference
          put     "/"     => :update,           :as => :twitter_user_buffer_preference
          delete  "/"     => :destroy,          :as => :twitter_user_buffer_preference
          get     "time"  => :new_tweet_time,   :as => :new_twitter_user_buffer_preference_tweet_time
        end

        post    "time" => "TimeDefinitions#create_time",  :as => :twitter_user_buffer_preference_tweet_time
      end
    end
  end


  resources :tweets

end
