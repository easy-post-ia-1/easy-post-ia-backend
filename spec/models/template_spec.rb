# frozen_string_literal: true

# == Schema Information
#
# Table name: templates
#
#  id          :bigint           not null, primary key
#  category    :string           not null
#  description :string(500)
#  emoji       :string           not null
#  image_url   :string
#  is_default  :boolean          default(FALSE), not null
#  tags        :string(255)
#  title       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  company_id  :bigint           not null
#  team_id     :bigint
#
# Indexes
#
#  index_templates_on_category              (category)
#  index_templates_on_company_id            (company_id)
#  index_templates_on_is_default            (is_default)
#  index_templates_on_team_id               (team_id)
#  index_templates_on_title_and_company_id  (title,company_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (team_id => teams.id)
#
require 'rails_helper'

RSpec.describe Template do
  describe 'associations' do
    it { should belong_to(:company) }
    it { should belong_to(:team).optional }
  end

  describe 'validations' do
    let(:company) { create(:company) }
    subject { build(:template, company: company) }
    
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(255) }
    it { should validate_length_of(:description).is_at_most(500) }
    it { should validate_length_of(:tags).is_at_most(255) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:emoji) }
    it { should validate_uniqueness_of(:title).scoped_to(:company_id) }
  end

  describe 'scopes' do
    let(:company) { create(:company) }
    let(:team) { create(:team, company: company) }

    describe '.default_templates' do
      let!(:default_template) { create(:template, :default, company: company) }
      let!(:team_template) { create(:template, :team_specific, company: company, team: team) }

      it 'returns only default templates without team' do
        expect(Template.default_templates).to include(default_template)
        expect(Template.default_templates).not_to include(team_template)
      end
    end

    describe '.team_templates' do
      let!(:default_template) { create(:template, :default, company: company) }
      let!(:team_template) { create(:template, :team_specific, company: company, team: team) }

      it 'returns only team templates' do
        expect(Template.team_templates).to include(team_template)
        expect(Template.team_templates).not_to include(default_template)
      end
    end

    describe '.by_company' do
      let(:other_company) { create(:company) }
      let!(:template1) { create(:template, company: company) }
      let!(:template2) { create(:template, company: other_company) }

      it 'returns templates for the specified company' do
        expect(Template.by_company(company.id)).to include(template1)
        expect(Template.by_company(company.id)).not_to include(template2)
      end
    end

    describe '.by_team' do
      let(:other_team) { create(:team, company: company) }
      let!(:template1) { create(:template, :team_specific, company: company, team: team) }
      let!(:template2) { create(:template, :team_specific, company: company, team: other_team) }

      it 'returns templates for the specified team' do
        expect(Template.by_team(team.id)).to include(template1)
        expect(Template.by_team(team.id)).not_to include(template2)
      end
    end

    describe '.available_for_team' do
      let!(:default_template) { create(:template, :default, company: company) }
      let!(:team_template) { create(:template, :team_specific, company: company, team: team) }
      let!(:other_team_template) { create(:template, :team_specific, company: company, team: create(:team, company: company)) }

      it 'returns default templates and team-specific templates' do
        available_templates = Template.available_for_team(team.id)
        expect(available_templates).to include(default_template)
        expect(available_templates).to include(team_template)
        expect(available_templates).not_to include(other_team_template)
      end
    end
  end

  describe '#template_type' do
    let(:company) { create(:company) }
    let(:team) { create(:team, company: company) }

    context 'when template is default and has no team' do
      let(:template) { build(:template, :default, company: company) }

      it 'returns company' do
        expect(template.template_type).to eq('company')
      end
    end

    context 'when template is not default or has a team' do
      let(:template) { build(:template, :team_specific, company: company, team: team) }

      it 'returns team' do
        expect(template.template_type).to eq('team')
      end
    end
  end

  describe '#can_be_managed_by?' do
    let(:company) { create(:company) }
    let(:team) { create(:team, company: company) }
    let(:template) { create(:template, company: company, team: team) }
    let(:user) { create(:user) }
    let!(:team_member) { create(:team_member, user: user, team: team) }

    context 'when user is admin' do
      before { user.add_role(:admin) }

      it 'returns true' do
        expect(template.can_be_managed_by?(user)).to be true
      end
    end

    context 'when user is employer' do
      before { user.add_role(:employer) }

      it 'returns true' do
        expect(template.can_be_managed_by?(user)).to be true
      end
    end

    context 'when user is employee' do
      before { user.add_role(:employee) }

      it 'returns false' do
        expect(template.can_be_managed_by?(user)).to be false
      end
    end

    context 'when user is from different company' do
      let(:other_company) { create(:company) }
      let(:other_team) { create(:team, company: other_company) }
      let!(:other_team_member) { create(:team_member, user: user, team: other_team) }

      before { user.add_role(:admin) }

      it 'returns false' do
        expect(template.can_be_managed_by?(user)).to be false
      end
    end
  end

  describe '#can_be_accessed_by?' do
    let(:company) { create(:company) }
    let(:team) { create(:team, company: company) }
    let(:template) { create(:template, company: company, team: team) }
    let(:user) { create(:user) }
    let!(:team_member) { create(:team_member, user: user, team: team) }

    context 'when user is from the same company' do
      it 'returns true' do
        expect(template.can_be_accessed_by?(user)).to be true
      end
    end

    context 'when user is from different company' do
      let(:other_company) { create(:company) }
      let(:other_team) { create(:team, company: other_company) }
      let!(:other_team_member) { create(:team_member, user: user, team: other_team) }

      it 'returns false' do
        expect(template.can_be_accessed_by?(user)).to be false
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:template)).to be_valid
    end
  end
end
