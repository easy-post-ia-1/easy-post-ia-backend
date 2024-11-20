# frozen_string_literal: true

# Add different values to Users auth
class AddFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    change_table :users, bulk: true do |t|
      t.string :username
      t.string :role
    end
  end
end
