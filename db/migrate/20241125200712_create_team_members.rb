# frozen_string_literal: true

# CreateTeamMembers migration
class CreateTeamMembers < ActiveRecord::Migration[7.2]
  def change
    create_table :team_members do |t|
      t.integer :user_id
      t.references :team, null: false, foreign_key: true
      t.integer :role_id

      t.timestamps
    end
  end
end
