# frozen_string_literal: true

# CreatePosts migration
class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.string :title, null: false, limit: 255
      t.string :description, limit: 500
      t.string :image_url
      t.string :tags, limit: 255
      t.datetime :programming_date_to_post, null: false
      t.boolean :is_published, default: false, null: false
      t.references :team_member, null: false, foreign_key: true

      t.timestamps
    end
  end
end
