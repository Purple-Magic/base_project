FactoryBot.define do
  factory :post do
    sequence(:content) { |n| "Post content #{n}" }
    user_id { create(:user).id }
  end
end
