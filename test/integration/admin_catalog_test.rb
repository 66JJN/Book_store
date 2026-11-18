require "test_helper"

class AdminCatalogTest < ActionDispatch::IntegrationTest
  setup do
    sign_in create_user("admin@example.test", role: "admin")
    @category = Category.create!(name: "Tech")
    @market = Market.create!(name: "Fair")
  end

  test "market form pages open" do
    get new_admin_market_url
    assert_response :success
    assert_select "input[name='market[name]']"

    get edit_admin_market_url(@market)
    assert_response :success
  end

  test "admin creates and renames a market" do
    assert_difference -> { Market.count } do
      post admin_markets_url, params: { market: { name: "Night Market" } }
    end

    market = Market.find_by!(name: "Night Market")
    patch admin_market_url(market), params: { market: { name: "Day Market" } }
    assert_equal "Day Market", market.reload.name
  end

  test "a blank market name shows the form with errors" do
    assert_no_difference -> { Market.count } do
      post admin_markets_url, params: { market: { name: "" } }
    end
    assert_select ".inline-errors", text: /can't be blank/
  end

  test "admin deletes an empty market" do
    assert_difference -> { Market.count }, -1 do
      delete admin_market_url(@market)
    end
    assert_redirected_to admin_markets_url
    assert_equal "Market was successfully deleted.", flash[:notice]
  end

  test "admin cannot delete a market that still has books" do
    @market.books << Book.create!(title: "Rails", author: "Team", isbn: "9780000000001", price: 1, stock: 1, category: @category)

    assert_no_difference -> { Market.count } do
      delete admin_market_url(@market)
    end
    assert_redirected_to admin_markets_url
    assert_match "Cannot delete record because dependent market books exist", flash[:alert]
  end

  test "admin deletes an empty category" do
    assert_difference -> { Category.count }, -1 do
      delete admin_category_url(@category)
    end
    assert_redirected_to admin_categories_url
    assert_equal "Category was successfully deleted.", flash[:notice]
  end
end
