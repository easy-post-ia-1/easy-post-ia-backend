# frozen_string_literal: true

# == Schema Information
#
# Table name: strategies
#
#  id               :bigint           not null, primary key
#  description      :string
#  error_response   :json
#  from_schedule    :datetime
#  status           :integer
#  success_response :json
#  to_schedule      :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  company_id       :bigint           not null
#  team_member_id   :bigint           not null
#
# Indexes
#
#  index_strategies_on_company_id      (company_id)
#  index_strategies_on_team_member_id  (team_member_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (team_member_id => team_members.id)
#
require 'rails_helper'

RSpec.describe Strategy, type: :model do
  let(:strategy) { create(:strategy) }

  it 'is valid with valid attributes' do
    expect(strategy).to be_valid
  end

  it 'is not valid without a description' do
    strategy.description = nil
    expect(strategy).not_to be_valid
    expect(strategy.errors[:description]).to include("can't be blank")
  end

  it 'is not valid without a from_schedule' do
    strategy.from_schedule = nil
    expect(strategy).not_to be_valid
    expect(strategy.errors[:from_schedule]).to include("can't be blank")
  end

  it 'is not valid without a to_schedule' do
    strategy.to_schedule = nil
    expect(strategy).not_to be_valid
    expect(strategy.errors[:to_schedule]).to include("can't be blank")
  end

  it 'is not valid if to_schedule is before from_schedule' do
    strategy.from_schedule = Date.today
    strategy.to_schedule = 1.day.ago
    expect(strategy).not_to be_valid
    expect(strategy.errors[:to_schedule]).to include("must be after or equal to From schedule")
  end

  describe 'associations' do
    it { should have_many(:posts) }
    it { should belong_to(:company).optional }
  end
end
