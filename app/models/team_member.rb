# frozen_string_literal: true

# == Schema Information
#
# Table name: team_members
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  role_id    :integer
#  team_id    :bigint           not null
#  user_id    :integer
#
# Indexes
#
#  index_team_members_on_team_id  (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#
class TeamMember < ApplicationRecord
  belongs_to :user
  belongs_to :team
  has_many :posts
  has_many :strategies

  validates :user_id, uniqueness: { scope: :team_id }
end
