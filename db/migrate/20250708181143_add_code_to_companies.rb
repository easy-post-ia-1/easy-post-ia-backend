# frozen_string_literal: true

class AddCodeToCompanies < ActiveRecord::Migration[7.2]
  def change
    add_column :companies, :code, :string
    add_index :companies, :code, unique: true
  end
end
