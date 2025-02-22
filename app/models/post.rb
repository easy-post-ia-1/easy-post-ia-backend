# frozen_string_literal: true

# == Schema Information
#
# Table name: posts
#
#  id                       :bigint           not null, primary key
#  description              :string(500)
#  image_url                :string
#  is_published             :boolean          default(FALSE), not null
#  programming_date_to_post :datetime         not null
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
  belongs_to :strategy

  def self.programming_date_to_cron(post_id)
    post = Post.find_by(id: post_id)
    return nil unless post

    post.programming_date_to_post.strftime('%M %H %d %m *')
  end
end
