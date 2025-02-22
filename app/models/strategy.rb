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
    in_progress: 1,
    completed: 2,
    failed: 3,
    cancelled: 4,
    approved: 5,
    scheduled: 6
  }

  # Validations
  validates :from_schedule, :to_schedule, presence: true
  validates :description, presence: true, allow_blank: true
  validates :status, presence: true
end
