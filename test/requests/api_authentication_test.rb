require "test_helper"

class ApiAuthenticationTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(email_address: "admin@example.test", password: "password123", role: :admin)
    @reader = User.create!(email_address: "reader@example.test", password: "password123", role: :user)
    @category = Category.create!(name: "Technology")
    @book = Book.create!(title: "Rails", author: "Rails Team", isbn: "9780000000002", price: 10, stock: 1, category: @category)
  end

  test "unauthenticated API request returns JSON 401" do
    get api_books_path

    assert_response :unauthorized
    assert_equal "Authentication required", response.parsed_body["error"]
  end

  test "admin can create market and reader receives 403" do
    post api_session_path, params: { email_address: @admin.email_address, password: "password123" }, as: :json
    post api_markets_path, params: { market: { name: "Central" } }, as: :json
    assert_response :created

    delete api_session_path
    post api_session_path, params: { email_address: @reader.email_address, password: "password123" }, as: :json
    post api_markets_path, params: { market: { name: "Forbidden" } }, as: :json
    assert_response :forbidden
  end

  test "admin book update replaces market assignments" do
    first_market = Market.create!(name: "First")
    second_market = Market.create!(name: "Second")
    @book.markets << first_market

    post api_session_path, params: { email_address: @admin.email_address, password: "password123" }, as: :json
    patch api_book_path(@book), params: { book: { market_ids: [ second_market.id ] } }, as: :json

    assert_response :success
    assert_equal [ second_market ], @book.reload.markets.to_a
  end

  test "admin can create a book with Thai category and market names" do
    market = Market.create!(name: "ตลาดนัดหนังสือ")
    @category.update!(name: "การเงิน")

    post api_session_path, params: { email_address: @admin.email_address, password: "password123" }, as: :json
    post api_books_path, params: {
      book: { title: "หุ้นมือใหม่", author: "พี่ดิว", isbn: "9780000000003", price: 299, stock: 5,
              category_name: "การเงิน", market_names: [ "ตลาดนัดหนังสือ" ] }
    }, as: :json

    assert_response :created
    assert_equal "การเงิน", response.parsed_body.dig("book", "category", "name")
    assert_equal [ market.name ], response.parsed_body.dig("book", "markets").pluck("name")
  end
end

class ApiAccessTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(email_address: "admin@example.test", password: "password123", role: :admin)
    @reader = User.create!(email_address: "reader@example.test", password: "password123", role: :user)
  end

  def login(user)
    post api_session_path, params: { email_address: user.email_address, password: "password123" }, as: :json
  end

  test "login returns the user in the old JSON shape" do
    login(@admin)

    assert_response :success
    assert_equal({ "id" => @admin.id, "email_address" => "admin@example.test", "role" => "admin" },
                 response.parsed_body["user"].except("created_at"))
  end

  test "wrong password is rejected" do
    post api_session_path, params: { email_address: @admin.email_address, password: "wrong-password" }, as: :json

    assert_response :unauthorized
    assert_equal "Invalid email or password", response.parsed_body["error"]
  end

  test "logout ends the session" do
    login(@reader)
    delete api_session_path
    assert_response :no_content

    get api_books_path
    assert_response :unauthorized
  end

  test "reader can list books but not users" do
    login(@reader)

    get api_books_path
    assert_response :success

    get api_users_path
    assert_response :forbidden
    assert_equal "Admin access is required", response.parsed_body["error"]
  end

  test "admin creates a user, promotes them, and never sees the password hash" do
    login(@admin)

    post api_users_path, params: { user: { email_address: "new@example.test", password: "password123", password_confirmation: "password123", role: "user" } }, as: :json
    assert_response :created
    user_id = response.parsed_body.dig("user", "id")

    patch api_user_path(user_id), params: { user: { role: "admin" } }, as: :json
    assert_response :success
    assert_equal "admin", response.parsed_body.dig("user", "role")
    assert User.find(user_id).admin?

    get api_users_path
    assert_nil response.parsed_body["users"].first["encrypted_password"]
  end

  test "admin cannot demote themselves through the API" do
    login(@admin)

    patch api_user_path(@admin), params: { user: { role: "user" } }, as: :json
    assert_response :unprocessable_entity
    assert @admin.reload.admin?
  end

  test "admin cannot delete their own account through the API" do
    login(@admin)

    delete api_user_path(@admin)
    assert_response :forbidden
  end

  test "an unknown email is rejected like a wrong password" do
    post api_session_path, params: { email_address: "nobody@example.test", password: "password123" }, as: :json

    assert_response :unauthorized
    assert_equal "Invalid email or password", response.parsed_body["error"]
  end
end
