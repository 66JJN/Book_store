require "test_helper"

class ApiUsersTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_user("admin@example.test", role: "admin")
    @reader = create_user("reader@example.test")
  end

  test "admin shows one user" do
    api_login(@admin)
    get api_user_path(@reader)

    assert_response :success
    assert_equal "reader@example.test", response.parsed_body.dig("user", "email_address")
    assert_equal "user", response.parsed_body.dig("user", "role")
  end

  test "create with invalid data returns the errors" do
    api_login(@admin)

    assert_no_difference -> { User.count } do
      post api_users_path, params: { user: { email_address: @reader.email, password: "short", role: "boss" } }, as: :json
    end
    assert_response :unprocessable_entity
    errors = response.parsed_body["errors"]
    assert_includes errors, "Email has already been taken"
    assert_includes errors, "Role is not included in the list"
  end

  test "update without a password keeps the old one" do
    api_login(@admin)
    patch api_user_path(@reader), params: { user: { email_address: "renamed@example.test", password: "" } }, as: :json

    assert_response :success
    assert @reader.reload.valid_password?(TEST_PASSWORD)
    assert_equal "renamed@example.test", @reader.email
  end

  test "update with invalid data returns the errors" do
    api_login(@admin)
    patch api_user_path(@reader), params: { user: { email_address: "not-an-email" } }, as: :json

    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"], "Email is invalid"
  end

  test "admin deletes another user" do
    api_login(@admin)

    assert_difference -> { User.count }, -1 do
      delete api_user_path(@reader)
    end
    assert_response :no_content
  end

  test "reader cannot see, change or delete other users" do
    api_login(@reader)

    get api_user_path(@admin)
    assert_response :forbidden

    patch api_user_path(@admin), params: { user: { role: "user" } }, as: :json
    assert_response :forbidden
    assert @admin.reload.admin?

    assert_no_difference -> { User.count } do
      delete api_user_path(@admin)
    end
    assert_response :forbidden
  end

  test "a missing user returns 404 JSON" do
    api_login(@admin)
    get api_user_path(id: 0)

    assert_response :not_found
  end
end
