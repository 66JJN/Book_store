require "test_helper"

class MarketBookTest < ActiveSupport::TestCase
  setup do
    @market = Market.create!(name: "Fair")
    @book = Book.create!(title: "Rails", author: "Team", isbn: "9780000000001", price: 1, stock: 1, category: Category.create!(name: "Tech"))
  end

  test "a book is listed in the same market only once" do
    MarketBook.create!(market: @market, book: @book)
    duplicate = MarketBook.new(market: @market, book: @book)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:book_id], "has already been taken"
  end

  test "the same book can be in different markets" do
    MarketBook.create!(market: @market, book: @book)

    assert MarketBook.new(market: Market.create!(name: "Other"), book: @book).valid?
  end

  test "only market and book can be searched by ActiveAdmin" do
    assert_equal %w[market_id book_id], MarketBook.ransackable_attributes
    assert_equal %w[market book], MarketBook.ransackable_associations
  end
end
