# == Schema Information
#
# Table name: credentials_twitters
#
#  id                  :bigint           not null, primary key
#  access_token        :text
#  access_token_secret :text
#  api_key             :text
#  api_key_secret      :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  company_id          :bigint           not null
#
# Indexes
#
#  index_credentials_twitters_on_company_id  (company_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#
class Credentials::Twitter < ApplicationRecord
  belongs_to :company
  validates :company_id, uniqueness: true

  encrypts :api_key
  encrypts :api_key_secret
  encrypts :access_token
  encrypts :access_token_secret

  def has_credentials?
    api_key.present? && api_key_secret.present? && access_token.present? && access_token_secret.present?
  end
end
