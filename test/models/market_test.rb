require "test_helper"

class MarketTest < ActiveSupport::TestCase
  test "market name must be unique" do
    Market.create!(name: "Central")
    market = Market.new(name: "Central")

    assert_not market.valid?
    assert_includes market.errors[:name], "has already been taken"
  end
end
