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
  chat = Chat.find_or_create_by!(name: attributes[:name])
  members = attributes[:members].map { |member| User.find_by!(member) }

  chat.users = members
end
