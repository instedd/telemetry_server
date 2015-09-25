FactoryGirl.define do

  sequence :email do |n|
    "user-#{n}@domain.com"
  end

  factory :user do
    email
    password { Faker::Internet.password }
  end

  factory :installation do
    uuid { SecureRandom.uuid }
    last_reported_at { 1.day.ago }
    ip { Faker::Internet.ip_v4_address }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    application 'verboice'
  end

  factory :event do
    installation
  end
end
