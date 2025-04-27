FactoryBot.define do
  factory :post do
    title { Faker::Book.title }
    body { Faker::Lorem.paragraph }
    ip { Faker::Internet.ip_v4_address }
    user
  end
end
