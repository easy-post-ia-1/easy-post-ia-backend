# frozen_string_literal: true

class AddDidTutorialToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :did_tutorial, :boolean, default: false, null: false
  end
end
