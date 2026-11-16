require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = create_user("admin@example.test", role: "admin")
    @reader = create_user("reader@example.test")
  end

  test "only admins manage users" do
    assert UserPolicy.new(@admin, @reader).update?
    assert_not UserPolicy.new(@reader, @reader).index?
    assert_not UserPolicy.new(nil, @reader).show?
  end

  test "an admin cannot delete their own account" do
    assert UserPolicy.new(@admin, @reader).destroy?
    assert_not UserPolicy.new(@admin, @admin).destroy?
    assert_not ActiveAdmin::UserPolicy.new(@admin, @admin).destroy?
    assert ActiveAdmin::UserPolicy.new(@admin, @reader).destroy?
  end

  test "the admin area policy shuts out readers even where the public policy allows" do
    book_class = Book

    assert BookPolicy.new(@reader, book_class).index?
    assert_not ActiveAdmin::ApplicationPolicy.new(@reader, book_class).index?
    assert ActiveAdmin::ApplicationPolicy.new(@admin, book_class).index?
  end
end
