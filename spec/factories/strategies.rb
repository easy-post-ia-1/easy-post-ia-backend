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
#
FactoryBot.define do
  factory :strategy do
    description { 'Test strategy' }
    from_schedule { Time.current }
    to_schedule { 1.day.from_now }
    status { 1 }

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
