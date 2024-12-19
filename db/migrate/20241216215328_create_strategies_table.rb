# frozen_string_literal: true

# Migrartion to create the strategies table
class CreateStrategiesTable < ActiveRecord::Migration[7.2]
  def change
    create_table :strategies do |t|
      t.datetime :from_schedule
      t.datetime :to_schedule
      t.string :description
      t.integer :status
      t.json :success_response
      t.json :error_response

      t.timestamps
    end
  end
end
