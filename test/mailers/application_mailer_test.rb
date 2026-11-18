require "test_helper"

class ApplicationMailerTest < ActionMailer::TestCase
  test "mail is sent from the default address with the mailer layout" do
    assert_equal "from@example.com", ApplicationMailer.default[:from]
    assert_equal "mailer", ApplicationMailer._layout
  end
end
