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
class StrategySerializer < ActiveModel::Serializer
  attributes :id, :description, :status_display, :from_schedule, :to_schedule, :post_ids

  def post_ids
    object.posts.pluck(:id)
  end
end
