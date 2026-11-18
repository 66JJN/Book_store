require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "name is required and unique" do
    Category.create!(name: "Tech")

    assert_includes Category.new(name: "").tap(&:valid?).errors[:name], "can't be blank"
    assert_includes Category.new(name: "Tech").tap(&:valid?).errors[:name], "has already been taken"
  end

  test "a category with books cannot be deleted" do
    category = Category.create!(name: "Tech")
    Book.create!(title: "Rails", author: "Team", isbn: "9780000000001", price: 1, stock: 1, category:)

    assert_not category.destroy
    assert_includes category.errors.full_messages, "Cannot delete record because dependent books exist"
  end

  test "an empty category can be deleted" do
    category = Category.create!(name: "Empty")

    assert category.destroy
  end
end
