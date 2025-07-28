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
FactoryBot.define do
  factory :strategy do
    description do
      ['Q1 Marketing Campaign', 'Product Launch Strategy', 'Social Media Engagement Plan', 'Brand Awareness Initiative',
       'Customer Retention Program'].sample
    end
    from_schedule { Time.current }
    to_schedule { 1.day.from_now }
    status { %i[pending in_progress completed].sample }
    success_response { { message: 'Strategy created successfully' } }
    error_response { { message: 'No error' } }
    company
    team_member

    transient do
      posts { [] }
    end

    after(:build) do |strategy, evaluator|
      strategy.posts = evaluator.posts if evaluator.posts.present?
    end

    after(:create) do |strategy, evaluator|
      strategy.posts = evaluator.posts if evaluator.posts.present?
      strategy.save! if evaluator.posts.present?
    end
  end
end
