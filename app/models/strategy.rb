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
class Strategy < ApplicationRecord
  # Associations
  has_many :posts, dependent: :restrict_with_error

  # Enum definition for status startegy
  enum :status, {
    pending: 0,
    in_progress_scheduling: 1,
    in_progress_config: 2,
    in_progress_posting: 3,
    completed: 4,
    failed: 5,
    failed_img: 6,
    failed_text: 8,
    failed_system: 9,
    failed_social_network: 10,
    cancelled: 11,
    approved: 12,
    scheduled: 13,
    posted: 14
  }

  # Validations
  # validates :from_schedule, :to_schedule,
  validates :description, presence: true, allow_blank: true
  validates :status, presence: true, inclusion: { in: statuses.keys }

  before_validation :set_default_status, on: :create

  private

  def set_default_status
    self.status ||= :pending
    self.description ||= ''
  end
end
