class Market < ApplicationRecord
  has_many :market_books, dependent: :restrict_with_error
  has_many :books, through: :market_books

  validates :name, presence: true, uniqueness: true
end
