class CreateCredentialsTwitters < ActiveRecord::Migration[7.2]
  def change
    create_table :credentials_twitters do |t|
      t.text :api_key
      t.text :api_key_secret
      t.text :access_token
      t.text :access_token_secret
      t.references :company, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
