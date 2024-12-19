# frozen_string_literal: true

# Update table Strategy
class AddStrategyToPosts < ActiveRecord::Migration[7.2]
  def change
    add_reference :posts, :strategy, null: true, foreign_key: true, default: nil
  end
end
