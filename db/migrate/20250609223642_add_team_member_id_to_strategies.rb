# frozen_string_literal: true

class AddTeamMemberIdToStrategies < ActiveRecord::Migration[7.2]
  def change
    add_reference :strategies, :team_member, null: false, foreign_key: true
  end
end
