require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # sign_in @user logs in directly (Warden test mode). The sign-in form itself
  # is covered by test/integration/store_access_test.rb.
  include Devise::Test::IntegrationHelpers
end
