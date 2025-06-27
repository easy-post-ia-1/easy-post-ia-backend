FactoryBot.define do
  factory :company_member do
    association :user
    association :company
    # Add any other required attributes here if needed
  end
end 