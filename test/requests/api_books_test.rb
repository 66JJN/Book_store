require "test_helper"

class ApiBooksTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_user("admin@example.test", role: "admin")
    @reader = create_user("reader@example.test")
    @tech = Category.create!(name: "Technology")
    @novel = Category.create!(name: "Novel")
    @rails = Book.create!(title: "Rails Guide", author: "Rails Team", isbn: "9780000000001", price: 10, stock: 1, category: @tech)
    @ruby = Book.create!(title: "Ruby Basics", author: "Matz", isbn: "9780000000002", price: 20, stock: 2, category: @tech)
    @story = Book.create!(title: "A Story", author: "Writer", isbn: "9780000000003", price: 5, stock: 3, category: @novel)
  end

  def login(user)
    post api_session_path, params: { email_address: user.email_address, password: TEST_PASSWORD }, as: :json
  end

  def titles = response.parsed_body["books"].pluck("title")

  test "index lists books ordered by title" do
    login(@reader)
    get api_books_path

    assert_response :success
    assert_equal [ "A Story", "Rails Guide", "Ruby Basics" ], titles
  end

  test "index filters by category" do
    login(@reader)
    get api_books_path, params: { category_id: @novel.id }

    assert_equal [ "A Story" ], titles
  end

  test "index searches title, author and isbn without caring about case" do
    login(@reader)

    get api_books_path, params: { q: "rails" }
    assert_equal [ "Rails Guide" ], titles

    get api_books_path, params: { q: "MATZ" }
    assert_equal [ "Ruby Basics" ], titles

    get api_books_path, params: { q: "0003" }
    assert_equal [ "A Story" ], titles
  end

  test "show returns the book with its category and markets" do
    market = Market.create!(name: "Fair")
    @rails.markets << market
    login(@reader)

    get api_book_path(@rails)

    assert_response :success
    book = response.parsed_body["book"]
    assert_equal "Rails Guide", book["title"]
    assert_equal "Technology", book.dig("category", "name")
    assert_equal [ "Fair" ], book["markets"].pluck("name")
  end

  test "show returns 404 JSON for a missing book" do
    login(@reader)
    get api_book_path(id: 0)

    assert_response :not_found
    assert_equal "Not found", response.parsed_body["error"]
  end

  test "admin creates a book" do
    login(@admin)

    assert_difference -> { Book.count } do
      post api_books_path, params: { book: { title: "New", author: "Me", isbn: "9780000000099", price: 1, stock: 1, category_id: @tech.id } }, as: :json
    end
    assert_response :created
  end

  test "create with invalid data returns the errors" do
    login(@admin)

    assert_no_difference -> { Book.count } do
      post api_books_path, params: { book: { title: "", author: "", isbn: @rails.isbn, price: -1, stock: 1, category_id: @tech.id } }, as: :json
    end
    assert_response :unprocessable_entity
    errors = response.parsed_body["errors"]
    assert_includes errors, "Title can't be blank"
    assert_includes errors, "Isbn has already been taken"
    assert_includes errors, "Price must be greater than or equal to 0"
  end

  test "create without the book key returns 422" do
    login(@admin)
    # Sent as a form, not JSON, so Rails does not wrap the params under "book" for us
    post api_books_path, params: { title: "No wrapper" }

    assert_response :unprocessable_entity
    assert_match "book", response.parsed_body["errors"].first
  end

  test "reader cannot create a book" do
    login(@reader)
    post api_books_path, params: { book: { title: "Nope" } }, as: :json

    assert_response :forbidden
  end

  test "admin updates a book" do
    login(@admin)
    patch api_book_path(@rails), params: { book: { stock: 9 } }, as: :json

    assert_response :success
    assert_equal 9, @rails.reload.stock
  end

  test "update with invalid data returns the errors" do
    login(@admin)
    patch api_book_path(@rails), params: { book: { stock: -5 } }, as: :json

    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"], "Stock must be greater than or equal to 0"
    assert_equal 1, @rails.reload.stock
  end

  test "admin deletes a book" do
    login(@admin)

    assert_difference -> { Book.count }, -1 do
      delete api_book_path(@story)
    end
    assert_response :no_content
  end

  test "reader cannot delete a book" do
    login(@reader)

    assert_no_difference -> { Book.count } do
      delete api_book_path(@story)
    end
    assert_response :forbidden
  end
end
