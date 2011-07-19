Tweetbuffer::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users

  root :to => 'Home#index'
  
  scope "dashboard" do
    controller :dashboard do
      get "" => :show, :as => :dashboard
      get "settings/account" => :account, :as => :account_settings
      get "settings/twitter" => :twitter, :as => :twitter_settings
    end
  end
  
end
