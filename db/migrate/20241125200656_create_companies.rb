# frozen_string_literal: true

# CreateCompanies migration
class CreateCompanies < ActiveRecord::Migration[7.2]
  def change
    create_table :companies do |t|
      t.string :name

      t.timestamps
    end
  end
end
