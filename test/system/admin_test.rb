require "application_system_test_case"

class AdminSystemTest < ApplicationSystemTestCase
  setup do
    @admin = create_user("admin@example.test", role: "admin")
    @reader = create_user("reader@example.test")
    @category = Category.create!(name: "Tech")
    @book = Book.create!(title: "Rails", author: "Team", isbn: "9780000000001", price: 100, stock: 1, category: @category)
  end

  test "a reader cannot open the admin area" do
    sign_in @reader
    visit admin_root_path

    assert_text "You are not authorized to perform this action."
    assert_selector "h1", text: "หนังสือทั้งหมด"
  end

  test "an admin edits a book's price from the store and sees it in the store" do
    sign_in @admin
    visit root_path
    assert_link "Admin"

    visit book_path(@book)
    click_on "Edit in admin"
    assert_field "Price", with: "100.0"
    fill_in "Price", with: "150"
    click_on "Update Book"
    assert_text "Book was successfully updated."

    visit book_path(@book)
    assert_text "Price: $150.00"
  end

  test "an admin adds a new category and it shows up in the store" do
    sign_in @admin
    visit new_admin_category_path

    fill_in "Name", with: "Cooking"
    click_on "Create Category"
    assert_text "Category was successfully created."

    visit root_path
    within("section[aria-label='Book categories']") { assert_link "Cooking" }
  end

  test "an admin gets an error when deleting a category that still has books" do
    sign_in @admin
    visit admin_category_path(@category)

    accept_confirm { click_on "Delete Category" }

    assert_text "Cannot delete record because dependent books exist"
    assert Category.exists?(@category.id)
  end
end
