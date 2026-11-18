require "test_helper"

class RoleTest < ActiveSupport::TestCase
  test "ActiveAdmin can search roles by id and name only" do
    assert_equal %w[id name], Role.ransackable_attributes
    assert_empty Role.ransackable_associations
  end

  test "resource_type must be a Rolify resource when it is set" do
    assert Role.new(name: "admin").valid?
    assert_not Role.new(name: "admin", resource_type: "NotAModel").valid?
  end
end
