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
require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:strategy) do
    create(:strategy, from_schedule: Time.current, to_schedule: 1.hour.from_now, status: :in_progress)
  end
  let(:team_member) { create(:team_member) }
  let(:post) do
    create(:post, programming_date_to_post: Time.new(2025, 3, 15, 14, 30), strategy: strategy, team_member: team_member)
  end

  describe '#fields' do
    it { is_expected.to have_db_column(:title).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:string) }
    it { is_expected.to have_db_column(:tags).of_type(:string) }
    it { is_expected.to have_db_column(:programming_date_to_post).of_type(:datetime) }
  end

  describe '#associations' do
    it { is_expected.to belong_to(:team_member) }
    it { is_expected.to belong_to(:strategy).optional }
  end

  describe '#validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:programming_date_to_post) }
  end

  describe '.programming_date_to_cron' do
    it 'returns a cron format for the given post' do
      cron_expression = Post.programming_date_to_cron(post.id)
      expect(cron_expression).to eq('30 14 15 03 *')
    end

    it 'returns nil if the post does not exist' do
      expect(Post.programming_date_to_cron(nil)).to be_nil
    end
  end

  it 'is valid with valid attributes' do
    expect(post).to be_valid
  end

  it 'is not valid without a title' do
    post.title = nil
    expect(post).not_to be_valid
    expect(post.errors[:title]).to include("can't be blank")
  end

  it 'is not valid without a description' do
    post.description = nil
    expect(post).not_to be_valid
    expect(post.errors[:description]).to include("can't be blank")
  end

  it 'is not valid without programming_date_to_post' do
    post.programming_date_to_post = nil
    expect(post).not_to be_valid
    expect(post.errors[:programming_date_to_post]).to include("can't be blank")
  end

  it 'is not valid without a team_member' do
    post.team_member = nil
    expect(post).not_to be_valid
    expect(post.errors[:team_member]).to include("must exist")
  end

  it 'is not valid without a strategy' do
    post.strategy = nil
    expect(post).not_to be_valid
    expect(post.errors[:strategy]).to include("must exist")
  end

  describe 'associations' do
    it { should belong_to(:team_member) }
    it { should belong_to(:strategy) }
  end
end
