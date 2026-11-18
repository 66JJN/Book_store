require "test_helper"

class ApplicationPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = create_user("admin@example.test", role: "admin")
  end

  test "everything is denied by default, even for admins" do
    policy = ApplicationPolicy.new(@admin, Object.new)

    assert_not policy.index?
    assert_not policy.show?
    assert_not policy.create?
    assert_not policy.new?
    assert_not policy.update?
    assert_not policy.edit?
    assert_not policy.destroy?
  end

  test "new? and edit? follow create? and update?" do
    policy = CatalogPolicy.new(@admin, Book)

    assert policy.new?
    assert policy.edit?
    assert_not CatalogPolicy.new(nil, Book).new?
  end

  test "a scope must define resolve" do
    error = assert_raises(NoMethodError) { ApplicationPolicy::Scope.new(@admin, Book).resolve }
    assert_match "You must define #resolve", error.message
  end
end
