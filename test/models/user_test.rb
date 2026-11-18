require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "a new user gets the reader role" do
    user = create_user("new@example.test")

    assert user.has_role?(:reader)
    assert_not user.admin?
    assert_equal "user", user.role
  end

  test "role admin adds the Rolify admin role, role user removes it" do
    user = create_user("staff@example.test", role: "admin")
    assert user.admin?
    assert_equal "admin", user.role

    user.update!(role: "user")
    assert_not user.reload.admin?
    assert user.has_role?(:reader)
  end

  test "an unknown role is rejected" do
    user = User.new(email_address: "x@example.test", password: TEST_PASSWORD, role: "owner")

    assert_not user.valid?
    assert_includes user.errors[:role], "is not included in the list"
  end

  test "email_address is an alias of the Devise email column" do
    user = create_user("  Mixed@Example.TEST ")

    assert_equal "mixed@example.test", user.email
    assert_equal user, User.find_by(email_address: "mixed@example.test")
  end

  test "a bcrypt hash from has_secure_password still signs in" do
    user = create_user("legacy@example.test")
    user.update_column(:encrypted_password, BCrypt::Password.create("legacy-pass", cost: BCrypt::Engine::MIN_COST))

    assert user.reload.valid_password?("legacy-pass")
  end

  test "a user created with a role keeps it and does not also become a reader" do
    user = User.create!(email_address: "staff@example.test", password: TEST_PASSWORD, roles: [ Role.find_or_create_by!(name: "admin") ])

    assert user.admin?
    assert_not user.has_role?(:reader)
  end
end
