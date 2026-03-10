FactoryBot.define do
  factory :chat do
    sequence(:name) { |n| "Chat #{n}" }
  end
end
