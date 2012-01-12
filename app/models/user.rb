class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :referal_id

  with_options :dependent => :destroy do |u|
    u.has_many :preferences
    u.has_many :twitter_users
    u.has_many :buffer_preferences
    u.has_many :tweets
    u.has_many :subcriptions
    u.has_many :tweet_intervals
    u.has_many :team_members
    u.has_many :suggestions
  
    u.has_one  :bitly_api 
  end
  
  after_create :mark_as_free_subcription

  private
  
  def mark_as_free_subcription
    Subcription.create!(:user_id => self.id, :plan_id => Plan.find_by_name('Free'), :active => true)
  end

end