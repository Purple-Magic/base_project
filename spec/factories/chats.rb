FactoryBot.define do
  factory :chat do
    sequence(:name) { |n| "Chat #{n}" }
    association :creator, factory: :user
  end
end
