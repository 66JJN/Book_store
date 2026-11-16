class Market < ApplicationRecord
  has_many :market_books, dependent: :restrict_with_error
  has_many :books, through: :market_books

  validates :name, presence: true, uniqueness: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[name created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[books]
  end
end
