require "test_helper"

class BookTest < ActiveSupport::TestCase
  setup do
    @tech = Category.create!(name: "Technology")
    @novel = Category.create!(name: "Novel")
    @rails = Book.create!(title: "Rails Guide", author: "Rails Team", isbn: "9780000000001", price: 10, stock: 1, category: @tech)
    @story = Book.create!(title: "A Story", author: "Writer", isbn: "9780000000002", price: 5, stock: 3, category: @novel)
  end

  def build(**attrs)
    Book.new({ title: "T", author: "A", isbn: "9780000000099", price: 1, stock: 1, category: @tech }.merge(attrs))
  end

  test "a complete book is valid" do
    assert build.valid?
  end

  test "title, author and isbn are required" do
    book = build(title: "", author: "", isbn: "")

    assert_not book.valid?
    assert_includes book.errors[:title], "can't be blank"
    assert_includes book.errors[:author], "can't be blank"
    assert_includes book.errors[:isbn], "can't be blank"
  end

  test "isbn must be unique" do
    book = build(isbn: @rails.isbn)

    assert_not book.valid?
    assert_includes book.errors[:isbn], "has already been taken"
  end

  test "price cannot be negative" do
    assert_not build(price: -1).valid?
    assert build(price: 0).valid?
  end

  test "stock must be a whole number that is not negative" do
    assert_not build(stock: -1).valid?
    assert_not build(stock: 1.5).valid?
    assert build(stock: 0).valid?
  end

  test "a book needs a category" do
    book = build(category: nil)

    assert_not book.valid?
    assert_includes book.errors[:category], "must exist"
  end

  test "in_category filters by category and ignores a blank id" do
    assert_equal [ @story ], Book.in_category(@novel.id).to_a
    assert_equal 2, Book.in_category(nil).count
    assert_equal 2, Book.in_category("").count
  end

  test "search matches title, author or isbn without caring about case" do
    assert_equal [ @rails ], Book.search("rails guide").to_a
    assert_equal [ @story ], Book.search("WRITER").to_a
    assert_equal [ @story ], Book.search("0002").to_a
    assert_empty Book.search("nothing like this")
  end

  test "search treats % and _ as plain characters" do
    assert_empty Book.search("%")
    assert_empty Book.search("_")
  end

  test "a blank search returns every book" do
    assert_equal 2, Book.search(nil).count
    assert_equal 2, Book.search("").count
  end

  test "deleting a book removes its market links" do
    @rails.markets << Market.create!(name: "Fair")

    assert_difference -> { MarketBook.count }, -1 do
      @rails.destroy
    end
  end
end
