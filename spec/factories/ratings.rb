FactoryBot.define do
  factory :rating do
    value { rand(1..5) }
    user
    post
  end
end
