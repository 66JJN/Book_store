require "simplecov"
SimpleCov.start "rails" do
  add_group "Policies", "app/policies"
  add_group "Admin", "app/admin"
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  parallelize(workers: 1)

  # Test-only password. Never reuse it anywhere real.
  TEST_PASSWORD = "password123"

  def create_user(email, role: "user")
    User.create!(email_address: email, password: TEST_PASSWORD, role: role)
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers # gives sign_in / sign_out
end
