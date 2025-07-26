# frozen_string_literal: true

class AddCompanyIdToStrategies < ActiveRecord::Migration[7.2]
  def change
    add_reference :strategies, :company, null: false, foreign_key: true
  end
end
