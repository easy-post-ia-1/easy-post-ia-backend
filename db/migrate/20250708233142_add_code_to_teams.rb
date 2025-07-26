# frozen_string_literal: true

class AddCodeToTeams < ActiveRecord::Migration[7.2]
  def change
    add_column :teams, :code, :string
    add_index :teams, :code, unique: true
  end
end
