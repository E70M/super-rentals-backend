FactoryBot.define do
  factory :rental do
    title { Faker::Restaurant.name }
    owner { Faker::Name.name }
    city { Faker::Address.city }
    category { Faker::Restaurant.type }
    image { Faker::File.file_name(dir: 'foo/bar', name: 'baz', ext: 'jpg') }
    bedrooms { Faker::Device.build_number }
    description { Faker::Restaurant.description }
  end
end