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
class Post < ApplicationRecord
  belongs_to :team_member
  belongs_to :strategy, optional: true

  has_one :team, through: :team_member

  validates :title, presence: true
  validates :programming_date_to_post, presence: true
  validates :category, presence: true
  validates :emoji, presence: true

  attribute :status, :integer, default: 0

  enum :status, {
    pending: 0,
    publishing: 1,
    published: 2,
    failed_image: 3,
    failed_publish: 4,
    failed_network: 5,
    failed_auth: 6
  }

  def self.programming_date_to_cron(post_id)
    post = Post.find_by(id: post_id)
    return nil unless post

    post.programming_date_to_post.strftime('%M %H %d %m *')
  end

  def status_display
    {
      status: status,
      title: I18n.t("models.post.status.#{status}"),
      color: status_color
    }
  end

  private

  def status_color
    case status
    when 'pending'
      '#FFA500'
    when 'publishing'
      '#87CEEB'
    when 'published'
      '#90EE90'
    else
      '#FF0000'
    end
  end
end
