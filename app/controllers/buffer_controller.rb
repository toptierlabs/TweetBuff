class BufferController < ApplicationController
  before_filter :authenticate_user!
  
  respond_to :html, :js
  
  def index
    @tweets = current_user.tweets
  end
  
  
end