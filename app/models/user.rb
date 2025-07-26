# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  did_tutorial           :boolean          default(FALSE), not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :string
#  username               :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  rolify

  has_one :team_member
  has_one :team, through: :team_member
  has_many :strategies, through: :team_member, source: :strategies
  has_many :posts, through: :team_member, source: :posts

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true

  after_update :sync_rolify_role_with_string, if: :saved_change_to_role?

  ROLES = %w[EMPLOYER EMPLOYEE ADMIN].freeze

  def sync_rolify_role_with_string
    return unless role.present? && ROLES.include?(role)
    # Remove all roles except the current one
    (roles.pluck(:name) - [role.downcase]).each { |r| remove_role(r) }
    # Add the new role if not present
    add_role(role.downcase) unless has_role?(role.downcase)
  end

  def user_json_response
    response = serializable_hash(except: %i[id created_at updated_at role])
    # Get the first role name, ensuring the association is loaded
    user_roles = roles.to_a
    response['role'] = user_roles.first&.name || 'user'
    response
  end

  # Fallback method for company access if association fails
  def company
    team&.company
  end
end
