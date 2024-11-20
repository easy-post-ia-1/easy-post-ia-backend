# frozen_string_literal: true

# CreateJwtDenylist to handle revocation
class CreateJwtDenylist < ActiveRecord::Migration[7.2]
  def change
    create_table :jwt_denylist do |t|
      t.string :jti, null: false, index: true
      t.datetime :exp, null: false

      t.timestamps
    end
  end
end
