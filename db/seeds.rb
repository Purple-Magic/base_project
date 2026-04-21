# Seed users that appear as members in the demo chat show pages.
seed_users = [
  { first_name: 'Alice', last_name: 'Johnson' },
  { first_name: 'Bob', last_name: 'Miller' },
  { first_name: 'Carla', last_name: 'Nguyen' },
  { first_name: 'David', last_name: 'Brown' }
]

seed_users.each do |attributes|
  User.find_or_create_by!(attributes)
end

# Seed chats with stable names and member lists so chat show pages have meaningful content.
seed_chats = [
  {
    name: 'Product Planning',
    members: [
      { first_name: 'Alice', last_name: 'Johnson' },
      { first_name: 'Bob', last_name: 'Miller' },
      { first_name: 'Carla', last_name: 'Nguyen' }
    ]
  },
  {
    name: 'Customer Support',
    members: [
      { first_name: 'Bob', last_name: 'Miller' },
      { first_name: 'David', last_name: 'Brown' }
    ]
  }
]

seed_chats.each do |attributes|
  members = attributes[:members].map { |member| User.find_by!(member) }
  chat = Chat.find_or_create_by!(name: attributes[:name], creator: members.first)

  chat.users = members

  # Rebuild chat history on every seed run so each demo chat has a stable transcript size.
  Chats::Message.where(chat:).delete_all

  100.times do |index|
    Chats::Message.create!(
      chat:,
      sender: members[index % members.size],
      text: "##{index + 1} #{Faker::Lorem.sentence(word_count: rand(6..14))}",
      created_at: 100.minutes.ago + index.minutes,
      updated_at: 100.minutes.ago + index.minutes
    )
  end
end
