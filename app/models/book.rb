class Book < ApplicationRecord
  belongs_to :category
  has_many :market_books, dependent: :destroy
  has_many :markets, through: :market_books

  validates :title, :author, :isbn, presence: true
  validates :isbn, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :in_category, ->(category_id) { where(category_id:) if category_id.present? }
  scope :search, ->(query) do
    if query.present?
      term = "%#{sanitize_sql_like(query)}%"
      where("title ILIKE :term OR author ILIKE :term OR isbn ILIKE :term", term:)
    end
  end
end
