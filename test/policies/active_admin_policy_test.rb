require "test_helper"

class ActiveAdminPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = create_user("admin@example.test", role: "admin")
    @reader = create_user("reader@example.test")
    @category = Category.create!(name: "Tech")
  end

  test "guests and readers can do nothing in /admin, admins can do everything" do
    actions = %i[index? show? new? create? edit? update? destroy? destroy_all?]

    actions.each do |action|
      assert_equal false, ActiveAdmin::ApplicationPolicy.new(nil, Category).public_send(action), "guest #{action}"
      assert_equal false, ActiveAdmin::ApplicationPolicy.new(@reader, Category).public_send(action), "reader #{action}"
      assert_equal true, ActiveAdmin::ApplicationPolicy.new(@admin, Category).public_send(action), "admin #{action}"
    end
  end

  test "the admin scope shows every record only to admins" do
    assert_includes ActiveAdmin::ApplicationPolicy::Scope.new(@admin, Category).resolve, @category
    assert_empty ActiveAdmin::ApplicationPolicy::Scope.new(@reader, Category).resolve
    assert_empty ActiveAdmin::ApplicationPolicy::Scope.new(nil, Category).resolve
  end
end
