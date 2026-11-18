require "simplecov"
SimpleCov.start "rails" do
  # Also count both sides of every if / unless / ||, not just whether a line ran
  enable_coverage :branch
  # Fail the run under 90%. Only checked on request (CHECK_COVERAGE=1 bin/rails test:all),
  # because running a single test file covers only a small part of the app.
  minimum_coverage 90 if ENV["CHECK_COVERAGE"]

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

  # Logs in through the JSON API, the same way Bruno does
  def api_login(user)
    post api_session_path, params: { email_address: user.email_address, password: TEST_PASSWORD }, as: :json
  end
end
