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
require 'rails_helper'

RSpec.describe TeamMember do
  let(:team_member) { create(:team_member) }

  it 'is valid with valid attributes' do
    expect(team_member).to be_valid
  end

  it 'is not valid without a user' do
    team_member.user = nil
    expect(team_member).not_to be_valid
    expect(team_member.errors[:user]).to include('must exist')
  end

  it 'is not valid without a team' do
    team_member.team = nil
    expect(team_member).not_to be_valid
    expect(team_member.errors[:team]).to include('must exist')
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:team) }
    it { is_expected.to have_many(:posts) }
  end

  describe '#fields' do
    it { is_expected.to have_db_column(:user_id).of_type(:integer) }
    it { is_expected.to have_db_column(:team_id).of_type(:integer) }
  end
end
