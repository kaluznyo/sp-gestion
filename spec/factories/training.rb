FactoryGirl.define do
  factory :training do
    name(Faker::Lorem.words(3).join(' '))
    short_name(Faker::Lorem.words(1).join(' '))
  end
end
