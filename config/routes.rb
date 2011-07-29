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


    get     ":twitter_name"                     => "TwitterUser#index"
    get     ":twitter_name/buffers"             => "BufferPreference#index"
    post    ":twitter_name/buffers"             => "BufferPreference#create"
    get     ":twitter_name/buffers/new"         => "BufferPreference#new"
    get     ":twitter_name/:buffer_name"        => "BufferPreference#show"
    get     ":twitter_name/:buffer_name/edit"   => "BufferPreference#edit"
    put     ":twitter_name/:buffer_name"        => "BufferPreference#update"
    delete  ":twitter_name/:buffer_name"        => "BufferPreference#destroy"
  end






  resources :tweets


end
