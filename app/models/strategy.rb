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

  STATUS_COLOR_MAP = {
    pending: '#FFD700', # Gold/Yellow
    in_progress_scheduling: '#ADD8E6', # LightBlue
    in_progress_config: '#ADD8E6', # LightBlue
    in_progress_posting: '#ADD8E6', # LightBlue
    completed: '#90EE90', # LightGreen
    scheduled: '#90EE90', # LightGreen
    posted: '#90EE90', # LightGreen
    approved: '#90EE90', # LightGreen
    failed: '#F08080', # LightCoral/Red
    failed_img: '#F08080', # LightCoral/Red
    failed_text: '#F08080', # LightCoral/Red
    failed_system: '#F08080', # LightCoral/Red
    failed_social_network: '#F08080', # LightCoral/Red
    cancelled: '#D3D3D3' # LightGray
  }.freeze

  def status_display
    # self.status will return the string key of the enum, e.g., "pending"
    # self.class.statuses is a hash like {"pending"=>0, "completed"=>1, ...}
    # read_attribute_before_type_cast(:status) gives the integer value, e.g., 0
    # The enum definition itself makes `self.status` return the string key.
    status_key = self.status&.to_sym || :pending # Use self.status which returns the string key

    color = STATUS_COLOR_MAP[status_key] || '#808080' # Default to Gray

    {
      name: status_key.to_s.humanize.titleize,
      color: color,
      key: status_key
    }
  end

  private

  def set_default_status
    self.status ||= :pending
    self.description ||= ''
  end
end
