# frozen_string_literal: true

class CreateTemplates < ActiveRecord::Migration[7.2]
  def change
    create_table :templates do |t|
      t.string :title, null: false
      t.string :description, limit: 500
      t.string :image_url
      t.string :tags, limit: 255
      t.string :category, null: false
      t.string :emoji, null: false
      t.references :company, null: false, foreign_key: true
      t.references :team, null: true, foreign_key: true
      t.boolean :is_default, default: false, null: false

      t.timestamps
    end

    # Add indexes for performance (Rails auto-creates indexes for foreign keys)
    add_index :templates, :category
    add_index :templates, :is_default

    # Add unique constraint for title per company
    add_index :templates, %i[title company_id], unique: true
  end
end
