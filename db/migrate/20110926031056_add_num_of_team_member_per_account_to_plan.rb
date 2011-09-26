class AddNumOfTeamMemberPerAccountToPlan < ActiveRecord::Migration
  def self.up
    add_column :plans, :num_of_team_member_per_account, :integer
  end

  def self.down
    remove_column :plans, :num_of_team_member_per_account
  end
end
