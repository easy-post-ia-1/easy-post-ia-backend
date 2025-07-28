# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id            :bigint           not null, primary key
#  name          :string
#  resource_type :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  resource_id   :bigint
#
# Indexes
#
#  index_roles_on_name_and_resource_type_and_resource_id  (name,resource_type,resource_id)
#  index_roles_on_resource                                (resource_type,resource_id)
#
require 'rails_helper'

RSpec.describe Role do
  describe 'associations' do
    it { should have_and_belong_to_many(:users) }
    it { should belong_to(:resource).optional }
  end

  describe 'validations' do
    it { should validate_inclusion_of(:resource_type).in_array(Rolify.resource_types).allow_nil }
  end

  describe 'scopes' do
    it 'can create and find roles by name' do
      role = create(:role, name: 'admin')
      expect(Role.where(name: 'admin')).to include(role)
    end

    it 'can find roles by resource type' do
      # Use a valid resource type or nil
      role = create(:role, name: 'admin', resource_type: nil)
      expect(Role.where(resource_type: nil)).to include(role)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:role)).to be_valid
    end
  end
end
