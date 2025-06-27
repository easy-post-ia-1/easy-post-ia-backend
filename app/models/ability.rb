# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest

    if user.has_role?(:admin)
      can :manage, :all

    elsif user.has_role?(:employer)
      can :manage, Post, company_id: user.company_id
      can :manage, Strategy, company_id: user.company_id
      can :manage, Team, company_id: user.company_id
      can :manage, User, company_id: user.company_id
      can :read, Company, id: user.company_id

    elsif user.has_role?(:employee)
      can [:read, :update], Post, team_member: { user_id: user.id }
      can [:read, :update], Strategy, team_member: { user_id: user.id }
      can :read, User, id: user.id
      can :read, Company, id: user.company_id
      can :read, Team, team_members: { user_id: user.id }
    end
  end
end 