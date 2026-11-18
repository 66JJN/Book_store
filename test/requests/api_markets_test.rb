require "test_helper"

class ApiMarketsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_user("admin@example.test", role: "admin")
    @reader = create_user("reader@example.test")
    @central = Market.create!(name: "Central")
    @airport = Market.create!(name: "Airport")
  end

  def login(user)
    post api_session_path, params: { email_address: user.email_address, password: TEST_PASSWORD }, as: :json
  end

  test "index lists markets ordered by name" do
    login(@reader)
    get api_markets_path

    assert_response :success
    assert_equal [ "Airport", "Central" ], response.parsed_body["markets"].pluck("name")
  end

  test "show returns one market" do
    login(@reader)
    get api_market_path(@central)

    assert_response :success
    assert_equal({ "id" => @central.id, "name" => "Central" }, response.parsed_body["market"])
  end

  test "create with a duplicate name returns the errors" do
    login(@admin)

    assert_no_difference -> { Market.count } do
      post api_markets_path, params: { market: { name: "Central" } }, as: :json
    end
    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"], "Name has already been taken"
  end

  test "admin renames a market" do
    login(@admin)
    patch api_market_path(@central), params: { market: { name: "Downtown" } }, as: :json

    assert_response :success
    assert_equal "Downtown", @central.reload.name
  end

  test "update with a blank name returns the errors" do
    login(@admin)
    patch api_market_path(@central), params: { market: { name: "" } }, as: :json

    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"], "Name can't be blank"
  end

  test "reader cannot rename a market" do
    login(@reader)
    patch api_market_path(@central), params: { market: { name: "Hacked" } }, as: :json

    assert_response :forbidden
    assert_equal "Central", @central.reload.name
  end

  test "admin deletes an empty market" do
    login(@admin)

    assert_difference -> { Market.count }, -1 do
      delete api_market_path(@airport)
    end
    assert_response :no_content
  end

  test "a market that still has books cannot be deleted" do
    category = Category.create!(name: "Tech")
    @central.books << Book.create!(title: "Rails", author: "Team", isbn: "9780000000001", price: 1, stock: 1, category:)
    login(@admin)

    assert_no_difference -> { Market.count } do
      delete api_market_path(@central)
    end
    assert_response :unprocessable_entity
    assert_match "dependent market books exist", response.parsed_body["errors"].first
  end
end
