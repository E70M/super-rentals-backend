FactoryBot.define do
  factory :rental do
    title { "Grand Old Mansion" }
    owner { "Veruca Salt" }
    city { "San Francisco" }
    category { "Estate" }
    image { "https://upload.wikimedia.org/wikipedia/commons/c/cb/Crane_estate_(5).jpg" }
    bedrooms { 15 }
    description { "This grand old mansion sits on over 100 acres of rolling hills and dense redwood forests." }
  end
end