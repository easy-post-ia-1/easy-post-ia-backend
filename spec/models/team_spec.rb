# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id         :bigint           not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :bigint           not null
#
# Indexes
#
#  index_teams_on_code        (code) UNIQUE
#  index_teams_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#
require 'rails_helper'

RSpec.describe Team do
  let(:team) { create(:team) }

  it 'is valid with valid attributes' do
    expect(team).to be_valid
  end

  it 'is not valid without a code' do
    team.code = nil
    expect(team).not_to be_valid
    expect(team.errors[:code]).to include("can't be blank")
  end

  it 'is not valid with a duplicate code' do
    create(:team, code: 'DUPLICATE')
    duplicate_team = build(:team, code: 'DUPLICATE')
    expect(duplicate_team).not_to be_valid
    expect(duplicate_team.errors[:code]).to include('has already been taken')
  end

  describe 'associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to have_many(:team_members) }
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:strategies) }
    it { is_expected.to have_many(:posts) }
    it { is_expected.to have_many(:templates) }
  end

  describe '#fields' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:code).of_type(:string) }
    it { is_expected.to have_db_column(:company_id).of_type(:integer) }
  end
end
