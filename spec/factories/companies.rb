FactoryBot.define do
  factory :company do
    sequence(:name) { |n| "Company #{n}" }
    sequence(:ticker) { |n| "TIC#{n}" }
  end
end