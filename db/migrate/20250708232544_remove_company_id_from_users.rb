# frozen_string_literal: true

class RemoveCompanyIdFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :company_id, :bigint
  end
end
