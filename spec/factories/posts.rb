# frozen_string_literal: true

# == Schema Information
#
# Table name: posts
#
#  id                       :bigint           not null, primary key
#  category                 :string
#  description              :string(500)
#  emoji                    :string
#  image_url                :string
#  is_published             :boolean          default(FALSE), not null
#  programming_date_to_post :datetime         not null
#  status                   :integer
#  tags                     :string(255)
#  title                    :string(255)      not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  strategy_id              :bigint
#  team_member_id           :bigint           not null
#
# Indexes
#
#  index_posts_on_strategy_id     (strategy_id)
#  index_posts_on_team_member_id  (team_member_id)
#
# Foreign Keys
#
#  fk_rails_...  (strategy_id => strategies.id)
#  fk_rails_...  (team_member_id => team_members.id)
#
FactoryBot.define do
  factory :post do
    title { 'Super Test' }
    description { 'This is a post of test' }
    tags { 'tags1,tags2,tags3' }
    category { 'Marketing' }
    emoji { '🚀' }
    programming_date_to_post { '2024-11-25 15:07:44' }
    is_published { false }
    team_member
  end
end
