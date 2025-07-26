# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  did_tutorial           :boolean          default(FALSE), not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :string
#  username               :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require 'rails_helper'

RSpec.describe User do
  let(:user) { create(:user) }
  let(:admin) { create(:user, role: 'ADMIN') }
  let(:employee) { create(:user, role: 'EMPLOYEE') }
  let(:employer) { create(:user, role: 'EMPLOYER') }

  it 'is valid with valid attributes' do
    expect(user).to be_valid
  end

  it 'is not valid without a username' do
    user.username = nil
    expect(user).not_to be_valid
    expect(user.errors[:username]).to include("can't be blank")
  end

  it 'is not valid without an email' do
    user.email = nil
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("can't be blank")
  end

  it 'is not valid with a duplicate email' do
    create(:user, email: 'duplicate@example.com')
    duplicate_user = build(:user, email: 'duplicate@example.com')
    expect(duplicate_user).not_to be_valid
    expect(duplicate_user.errors[:email]).to include('has already been taken')
  end

  it 'is not valid with a duplicate username' do
    create(:user, username: 'duplicate_username')
    duplicate_user = build(:user, username: 'duplicate_username')
    expect(duplicate_user).not_to be_valid
    expect(duplicate_user.errors[:username]).to include('has already been taken')
  end

  it 'is not valid without a role' do
    user.role = nil
    expect(user).not_to be_valid
    expect(user.errors[:role]).to include("can't be blank")
  end

  it 'is not valid with an invalid role' do
    user.role = 'INVALID'
    expect(user).not_to be_valid
    expect(user.errors[:role]).to include('INVALID is not a valid role. The valid roles are EMPLOYER, EMPLOYEE, and ADMIN.')
  end

  it 'is valid with a valid role (ADMIN)' do
    expect(admin).to be_valid
  end

  it 'is valid with a valid role (EMPLOYEE)' do
    expect(employee).to be_valid
  end

  it 'is valid with a valid role (EMPLOYER)' do
    expect(employer).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_many(:team_members) }
    it { is_expected.to have_many(:company_members) }
  end
end
