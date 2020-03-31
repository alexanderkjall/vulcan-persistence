require 'test_helper'

class ChecksEnqueueJobTest < ActiveJob::TestCase
  setup do
    @check03 = checks(:check03)
    @check05 = checks(:check05)
    @check06 = checks(:check06)
  end

  test "checks are enqeueued" do
    ChecksEnqueueJob.perform_now([@check05, @check06], Time.now.to_s)

    @check05.reload
    @check06.reload

    assert_equal("QUEUED", @check05.status)
    assert_equal("QUEUED", @check06.status)
  end

  test "check with no scan_id is enqeueued" do
    ChecksEnqueueJob.perform_now([@check03], Time.now.to_s)

    @check03.reload

    assert_equal("QUEUED", @check03.status)
  end
end
