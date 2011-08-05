class AddPermalinks < ActiveRecord::Migration
  def self.up
    add_column :buffer_preferences, :permalink, :string
    add_column :twitter_users, :permalink, :string

    BufferPreference.all.each {|bp| bp.permalink = bp.to_param; bp.save;}
    TwitterUser.all.each {|tu| tu.permalink = tu.to_param; tu.save;}
  end

  def self.down
    remove_column :buffer_preferences, :permalink
    remove_column :twitter_users, :permalink
  end
end
