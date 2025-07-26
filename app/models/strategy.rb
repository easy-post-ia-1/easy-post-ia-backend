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
class Strategy < ApplicationRecord
  belongs_to :team_member
  belongs_to :company
  has_many :posts, dependent: :destroy

  validates :description, presence: true
  validates :from_schedule, presence: true
  validates :to_schedule, presence: true

  attribute :status, :integer, default: 0

  enum :status, {
    pending: 0,
    in_progress: 1,
    completed: 2,
    failed: 3
  }

  def status_display
    {
      status: status,
      title: I18n.t("models.strategy.status.#{status}"),
      color: status_color
    }
  end

  def posts_success_count
    posts.published.count
  end

  def posts_failed_count
    posts.where(status: %i[failed_image failed_publish failed_network failed_auth]).count
  end

  def posts_pending_count
    posts.pending.count
  end

  def posts_publishing_count
    posts.publishing.count
  end

  # Method to return the total count of posts
  delegate :count, to: :posts, prefix: true

  private

  def status_color
    case status
    when 'pending'
      '#FFA500'
    when 'in_progress'
      '#87CEEB'
    when 'completed'
      '#90EE90'
    else
      '#FF0000'
    end
  end
end
