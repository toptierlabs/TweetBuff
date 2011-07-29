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

    get     "/"                                 => "TwitterUsers#index",         :as => :twitter_users
    get     ":twitter_name/buffers"             => "BufferPreferences#index",    :as => :twitter_user_buffer_preferences
    post    ":twitter_name/buffers"             => "BufferPreferences#create",   :as => :twitter_user_buffer_preferences
    get     ":twitter_name/buffers/new"         => "BufferPreferences#new",      :as => :new_twitter_user_buffer_preference
    get     ":twitter_name/:buffer_name/edit"   => "BufferPreferences#edit",     :as => :edit_twitter_user_buffer_preference
    get     ":twitter_name/:buffer_name"        => "BufferPreferences#show",     :as => :twitter_user_buffer_preference
    put     ":twitter_name/:buffer_name"        => "BufferPreferences#update",   :as => :twitter_user_buffer_preference
    delete  ":twitter_name/:buffer_name"        => "BufferPreferences#destroy",  :as => :twitter_user_buffer_preference
  end


  resources :tweets


end
