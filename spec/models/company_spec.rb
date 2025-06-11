# frozen_string_literal: true

# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Company, type: :model do
  let(:company) { create(:company) }

  it 'is valid with valid attributes' do
    expect(company).to be_valid
  end

  it 'is not valid without a name' do
    company.name = nil
    expect(company).not_to be_valid
    expect(company.errors[:name]).to include("can't be blank")
  end

  it 'is not valid with a duplicate name' do
    create(:company, name: 'Duplicate Company')
    duplicate_company = build(:company, name: 'Duplicate Company')
    expect(duplicate_company).not_to be_valid
    expect(duplicate_company.errors[:name]).to include("has already been taken")
  end

  describe 'associations' do
    it { should have_many(:company_members) }
    it { should have_many(:strategies) }
    it { should have_one(:twitter_credential) }
  end

  describe '#fields' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
  end
end
