require "test_helper"

class ApiCategoriesTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_user("admin@example.test", role: "admin")
    @reader = create_user("reader@example.test")
    @tech = Category.create!(name: "Technology")
  end

  def login(user)
    post api_session_path, params: { email_address: user.email_address, password: TEST_PASSWORD }, as: :json
  end

  test "reader lists and shows categories" do
    login(@reader)

    get api_categories_path
    assert_response :success
    assert_equal [ "Technology" ], response.parsed_body["categories"].pluck("name")

    get api_category_path(@tech)
    assert_response :success
    assert_equal "Technology", response.parsed_body.dig("category", "name")
  end

  test "admin creates, renames and deletes a category" do
    login(@admin)

    post api_categories_path, params: { category: { name: "Cooking" } }, as: :json
    assert_response :created
    id = response.parsed_body.dig("category", "id")

    patch api_category_path(id), params: { category: { name: "Baking" } }, as: :json
    assert_response :success
    assert_equal "Baking", Category.find(id).name

    delete api_category_path(id)
    assert_response :no_content
    assert_not Category.exists?(id)
  end

  test "invalid category data returns the errors" do
    login(@admin)

    post api_categories_path, params: { category: { name: "" } }, as: :json
    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"], "Name can't be blank"

    patch api_category_path(@tech), params: { category: { name: "" } }, as: :json
    assert_response :unprocessable_entity
  end

  test "a category that still has books cannot be deleted" do
    Book.create!(title: "Rails", author: "Team", isbn: "9780000000001", price: 1, stock: 1, category: @tech)
    login(@admin)

    assert_no_difference -> { Category.count } do
      delete api_category_path(@tech)
    end
    assert_response :unprocessable_entity
  end

  test "reader cannot create a category" do
    login(@reader)
    post api_categories_path, params: { category: { name: "Nope" } }, as: :json

    assert_response :forbidden
  end
end
