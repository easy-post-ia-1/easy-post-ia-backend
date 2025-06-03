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

  after_initialize :set_defaults, if: :new_record?

  private

  def set_defaults
    self.api_key ||= ENV.fetch('TWITTER_API_KEY', nil)
    self.api_key_secret ||= ENV.fetch('TWITTER_API_KEY_SECRET', nil)
    self.access_token ||= ENV.fetch('TWITTER_ACCESS_TOKEN', nil)
    self.access_token_secret ||= ENV.fetch('TWITTER_ACCESS_TOKEN_SECRET', nil)
  end
end
