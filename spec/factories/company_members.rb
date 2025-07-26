# frozen_string_literal: true

FactoryBot.define do
  factory :company_member do
    user
    company
    # Add any other required attributes here if needed
  end
end
