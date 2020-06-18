class RentalResource < JSONAPI::Resource
  attributes :title, :owner, :city, :category, :image, :bedrooms, :description
end