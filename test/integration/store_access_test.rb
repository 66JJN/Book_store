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

  test "signing in with a wrong password shows an error" do
    post user_session_url, params: { user: { email: @reader.email, password: "wrong-password" } }

    assert_response :unprocessable_content
    assert_select "[role=alert]", text: "Invalid email or password."
  end

  test "sign up with mismatched passwords shows an error" do
    assert_no_difference -> { User.count } do
      post user_registration_url, params: { user: { email: "fresh@example.test", password: TEST_PASSWORD, password_confirmation: "something-else" } }
    end
    assert_response :unprocessable_content
    assert_match "Password confirmation doesn&#39;t match Password", response.body
  end

  test "a reader changes their email in My account" do
    sign_in @reader

    put user_registration_url, params: { user: { email: "renamed@example.test", current_password: TEST_PASSWORD } }

    assert_redirected_to root_url
    assert_equal "renamed@example.test", @reader.reload.email
  end

  test "My account needs the current password to save" do
    sign_in @reader

    put user_registration_url, params: { user: { email: "renamed@example.test", current_password: "wrong" } }

    assert_response :unprocessable_content
    assert_equal "reader@example.test", @reader.reload.email
  end

  test "the link in the reset email lets the reader set a new password" do
    post user_password_url, params: { user: { email: @reader.email } }
    token = ActionMailer::Base.deliveries.last.body.to_s[/reset_password_token=([^"&]+)/, 1]

    get edit_user_password_url(reset_password_token: token)
    assert_response :success

    put user_password_url, params: { user: { reset_password_token: token, password: "brand-new-pass", password_confirmation: "brand-new-pass" } }
    assert_redirected_to root_url
    assert @reader.reload.valid_password?("brand-new-pass")
  end
end
