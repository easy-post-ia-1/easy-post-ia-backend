# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest

    if user.has_role?(:admin)
      can :manage, :all

    elsif user.has_role?(:employer)
      can :manage, Post
      can :manage, Strategy
      can :manage, Team
      can :manage, User
      can :read, Company

    elsif user.has_role?(:employee)
      can %i[read update], Post, team_member: { user_id: user.id }
      can %i[read update], Strategy, team_member: { user_id: user.id }
      can :read, User, id: user.id
      can :read, Company
      can :read, Team, team_members: { user_id: user.id }
    end
  end
end
