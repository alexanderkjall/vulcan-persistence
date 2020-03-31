require 'test_helper'

class ChecksCreateEnqueueJobTest < ActiveJob::TestCase
  setup do
    @scan = scans(:scan04)
  end
  test 'checks are created and enqueued by streanming a S3 file' do
    FilescanProcessJob.perform_now(@scan.id, @scan.created_at.to_s,true)
    checks = Check.where(deleted_at: nil, scan_id: @scan.id)
    checks.each do |check|
      assert_equal(check['status'],'QUEUED')
    end
  end
end
