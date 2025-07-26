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
class Template < ApplicationRecord
  belongs_to :company
  belongs_to :team, optional: true

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 500 }
  validates :tags, length: { maximum: 255 }
  validates :category, presence: true
  validates :emoji, presence: true
  validates :title, uniqueness: { scope: :company_id }
  validates :title, uniqueness: { scope: :team_id }, if: -> { team_id.present? }

  scope :default_templates, -> { where(is_default: true, team_id: nil) }
  scope :team_templates, -> { where(is_default: false) }
  scope :by_company, ->(company_id) { where(company_id: company_id) }
  scope :by_team, ->(team_id) { where(team_id: team_id) }
  scope :available_for_team, ->(team_id) { where('team_id = ? OR (is_default = true AND team_id IS NULL)', team_id) }

  def template_type
    if is_default && team_id.nil?
      'company'
    else
      'team'
    end
  end

  def can_be_managed_by?(user)
    return false unless user.team_member&.team&.company_id == company_id

    user.has_role?(:admin) || user.has_role?(:employer)
  end

  def can_be_accessed_by?(user)
    return false unless user.team_member&.team&.company_id == company_id

    true # All team members can access templates
  end
end
