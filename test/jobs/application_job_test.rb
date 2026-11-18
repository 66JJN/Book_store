require "test_helper"

class ApplicationJobTest < ActiveJob::TestCase
  test "app jobs are Active Job jobs" do
    assert_operator ApplicationJob, :<, ActiveJob::Base
  end
end
