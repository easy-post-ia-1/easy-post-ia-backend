# frozen_string_literal: true

# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_companies_on_code  (code) UNIQUE
#
require 'rails_helper'

RSpec.describe Company do
  let(:company) { create(:company) }

  it 'is valid with valid attributes' do
    expect(company).to be_valid
  end

  it 'is not valid without a code' do
    company.code = nil
    expect(company).not_to be_valid
    expect(company.errors[:code]).to include("can't be blank")
  end

  it 'is not valid with a duplicate code' do
    create(:company, code: 'DUPLICATE')
    duplicate_company = build(:company, code: 'DUPLICATE')
    expect(duplicate_company).not_to be_valid
    expect(duplicate_company.errors[:code]).to include('has already been taken')
  end

  describe 'associations' do
    it { is_expected.to have_many(:teams) }
    it { is_expected.to have_many(:team_members) }
    it { is_expected.to have_many(:posts) }
    it { is_expected.to have_many(:strategies) }
    it { is_expected.to have_many(:templates) }
    it { is_expected.to have_one(:credentials_twitter) }
  end

  describe '#fields' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:code).of_type(:string) }
  end
end
