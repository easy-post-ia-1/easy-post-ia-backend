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
FactoryBot.define do
  factory :template do
    title { 'MyString' }
    description { 'MyString' }
    image_url { 'MyString' }
    tags { 'MyString' }
    category { 'MyString' }
    emoji { 'MyString' }
    company { nil }
    team { nil }
    is_default { false }
  end
end
