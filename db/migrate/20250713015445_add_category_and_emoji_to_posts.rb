# frozen_string_literal: true

class AddCategoryAndEmojiToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :category, :string
    add_column :posts, :emoji, :string
  end
end
