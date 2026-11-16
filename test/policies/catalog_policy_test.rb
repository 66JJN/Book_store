require "test_helper"

class CatalogPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = create_user("admin@example.test", role: "admin")
    @reader = create_user("reader@example.test")
    @category = Category.create!(name: "Tech")
    @book = Book.create!(title: "Rails", author: "Team", isbn: "9780000000001", price: 1, stock: 1, category: @category)
  end

  test "guests can browse but not change" do
    policy = BookPolicy.new(nil, @book)

    assert policy.index?
    assert policy.show?
    assert_not policy.create?
    assert_not policy.update?
    assert_not policy.destroy?
    assert_includes BookPolicy::Scope.new(nil, Book).resolve, @book
  end

  test "readers can browse but not change" do
    [ BookPolicy.new(@reader, @book), CategoryPolicy.new(@reader, @category), MarketPolicy.new(@reader, Market) ].each do |policy|
      assert policy.index?
      assert policy.show?
      assert_not policy.create?
      assert_not policy.update?
      assert_not policy.destroy?
    end
    assert_includes BookPolicy::Scope.new(@reader, Book).resolve, @book
  end

  test "admins can change the catalog" do
    policy = BookPolicy.new(@admin, @book)

    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end
end
