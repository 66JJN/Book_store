require "test_helper"

class StoreAccessTest < ActionDispatch::IntegrationTest
  setup do
    @reader = create_user("reader@example.test")
    category = Category.create!(name: "Tech")
    @book = Book.create!(title: "Rails", author: "Team", isbn: "9780000000001", price: 1, stock: 1, category: category)
  end

  test "guest can browse books but sees no admin button" do
    get books_url
    assert_response :success
    assert_select "a", text: "Sign in"

    get book_url(@book)
    assert_response :success
    assert_select "a", text: "Edit in admin", count: 0
  end

  test "guest is sent to sign in for My account" do
    get edit_user_registration_url
    assert_redirected_to new_user_session_url
  end

  test "reader can delete their own account" do
    sign_in @reader

    assert_difference -> { User.count }, -1 do
      delete user_registration_url
    end
  end

  test "admin cannot delete their own account from My account" do
    admin = create_user("boss@example.test", role: "admin")
    sign_in admin

    get edit_user_registration_url
    assert_select "button", text: "Delete my account", count: 0

    assert_no_difference -> { User.count } do
      delete user_registration_url
    end
    assert_redirected_to edit_user_registration_url
  end

  test "reader can browse and open a book, without an Admin link" do
    sign_in @reader

    get books_url
    assert_response :success
    assert_select "a", text: "Admin", count: 0

    get book_url(@book)
    assert_response :success
    assert_select "a", text: "Edit in admin", count: 0
  end

  test "admin sees an Edit in admin button on a book" do
    sign_in create_user("admin@example.test", role: "admin")

    get book_url(@book)
    assert_select "a[href=?]", edit_admin_book_path(@book), text: "Edit in admin"
  end

  test "forgot password sends a reset email" do
    assert_emails 1 do
      post user_password_url, params: { user: { email: @reader.email } }
    end
    assert_match "reset_password_token=", ActionMailer::Base.deliveries.last.body.to_s
  end

  test "signing in with the form works" do
    post user_session_url, params: { user: { email: @reader.email, password: TEST_PASSWORD } }
    assert_redirected_to root_url
  end

  test "signing up creates a reader" do
    assert_difference -> { User.count } do
      post user_registration_url, params: { user: { email: "fresh@example.test", password: TEST_PASSWORD, password_confirmation: TEST_PASSWORD } }
    end

    user = User.find_by!(email: "fresh@example.test")
    assert user.has_role?(:reader)
    assert_not user.admin?
  end

  test "the Devise pages render" do
    get new_user_session_url
    assert_response :success
    get new_user_registration_url
    assert_response :success
    get new_user_password_url
    assert_response :success
  end
end
