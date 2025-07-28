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

RSpec.describe Strategy do
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

  describe 'associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to belong_to(:team_member) }
    it { is_expected.to have_many(:posts) }
  end

  describe '#fields' do
    it { is_expected.to have_db_column(:description).of_type(:string) }
    it { is_expected.to have_db_column(:from_schedule).of_type(:datetime) }
    it { is_expected.to have_db_column(:to_schedule).of_type(:datetime) }
    it { is_expected.to have_db_column(:status).of_type(:integer) }
    it { is_expected.to have_db_column(:company_id).of_type(:integer) }
    it { is_expected.to have_db_column(:team_member_id).of_type(:integer) }
  end
end
