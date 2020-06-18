class Rental < ApplicationRecord
  # Existence
  validates :title, presence: true
  validates :owner, presence: true
  validates :city, presence: true
  validates :category, presence: true
  validates :image, presence: true
  validates :bedrooms, presence: true
  validates :description, presence: true

  # Uniqueness
  validates_uniqueness_of :title, scope: [:owner, :city, :category, :bedrooms]
end