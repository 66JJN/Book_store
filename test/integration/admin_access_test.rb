require "test_helper"

class AdminAccessTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_user("admin@example.test", role: "admin")
    @reader = create_user("reader@example.test")
    @category = Category.create!(name: "Tech")
    @market = Market.create!(name: "Fair")
    @book = Book.create!(title: "Rails", author: "Team", isbn: "9780000000001", price: 1, stock: 1, category: @category)
  end

  test "guest is sent to sign in" do
    get admin_root_url
    assert_redirected_to new_user_session_url
  end

  test "reader is turned away from every admin page" do
    sign_in @reader

    [ admin_root_url, admin_books_url, admin_categories_url, admin_markets_url, admin_users_url ].each do |url|
      get url
      assert_redirected_to root_url, url
    end
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "admin sees the Admin link and every admin page" do
    sign_in @admin

    get books_url
    assert_select "a[href=?]", admin_root_path, text: "Admin"

    [
      admin_root_url,
      admin_books_url, new_admin_book_url, admin_book_url(@book), edit_admin_book_url(@book),
      admin_categories_url, admin_category_url(@category), edit_admin_category_url(@category),
      admin_markets_url, admin_market_url(@market),
      admin_users_url, new_admin_user_url, admin_user_url(@reader), edit_admin_user_url(@reader)
    ].each do |url|
      get url
      assert_response :success, url
    end
  end

  test "every admin page has the store's Books button in the top bar" do
    sign_in @admin

    [ admin_root_url, admin_books_url, admin_users_url ].each do |url|
      get url
      assert_select "[data-test-site-title] + a[href=?]", books_path, text: "Books"
      assert_select "#main-menu a", text: /Back to store/, count: 0
    end
  end

  test "users CSV export does not leak password tokens" do
    @reader.send_reset_password_instructions
    sign_in @admin

    get admin_users_url(format: :csv)
    assert_response :success
    # ActiveAdmin starts CSV files with a UTF-8 BOM so Excel reads Thai correctly
    assert_equal "Id,Email,Roles,Created at", response.body.lines.first.delete_prefix("\uFEFF").strip
    assert_no_match(/reset.password|encrypted/i, response.body)
  end

  test "admin filters work" do
    sign_in @admin

    get admin_books_url, params: { q: { title_cont: "Rails", category_id_eq: @category.id } }
    assert_response :success
    get admin_users_url, params: { q: { email_cont: "reader" } }
    assert_response :success
  end

  test "admin creates a book with markets" do
    sign_in @admin

    assert_difference -> { Book.count } do
      post admin_books_url, params: { book: {
        title: "New", author: "Me", isbn: "9780000000099", price: 10, stock: 2,
        category_id: @category.id, market_ids: [ @market.id ]
      } }
    end
    assert_equal [ @market ], Book.find_by!(isbn: "9780000000099").markets.to_a
  end

  test "admin cannot delete a category that still has books" do
    sign_in @admin

    assert_no_difference -> { Category.count } do
      delete admin_category_url(@category)
    end
    assert_redirected_to admin_categories_url
    assert_match "Cannot delete record because dependent books exist", flash[:alert]
  end

  test "admin gives the admin role to a reader, who can then open /admin" do
    sign_in @admin
    patch admin_user_url(@reader), params: { user: { email: @reader.email, password: "", role_ids: Role.where(name: %w[admin reader]).ids } }
    assert @reader.reload.admin?

    sign_in @reader
    get admin_root_url
    assert_response :success
  end

  test "admin cannot untick their own admin role" do
    sign_in @admin

    patch admin_user_url(@admin), params: { user: { email: @admin.email, password: "", role_ids: [ "", Role.find_by!(name: "reader").id ] } }
    assert_redirected_to edit_admin_user_url(@admin)
    assert_equal "You cannot remove your own admin role.", flash[:alert]
    assert @admin.reload.admin?
  end

  test "admin cannot delete their own account" do
    sign_in @admin

    assert_no_difference -> { User.count } do
      delete admin_user_url(@admin)
    end
  end

  test "admin sets a new password for a user" do
    sign_in @admin

    patch admin_user_url(@reader), params: { user: { email: @reader.email, password: "brand-new-pass", password_confirmation: "brand-new-pass" } }

    assert @reader.reload.valid_password?("brand-new-pass")
  end

  test "the admin book page shows the cover image" do
    @book.update!(cover_image_url: "https://example.test/cover.jpg")
    sign_in @admin

    get admin_book_url(@book)
    assert_select "img[src=?]", "https://example.test/cover.jpg"
  end
end
