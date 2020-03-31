require 'test_helper'
require 'json'

class ChecksCreateEnqueueJobTest < ActiveJob::TestCase
  setup do
    @scan03 = scans(:scan03)
  end

  test 'checks are created and enqeueued' do
    checks_params = { scan: { checks: [{ check: { checktype_name: 'tls', target: 'localhost', options: '     ' } }, { check: { checktype_name: 'tls', target: 'www.example.com', options: '     ' } }] } }
    ChecksCreateEnqueueJob.perform_now(@scan03.id, @scan03.created_at.to_s, checks_params.to_json, true)
    @scan03.reload
    checks = Check.where(deleted_at: nil, scan_id: @scan03.id)

    assert_equal(checks.length, 2)

    checks.each do |check|
      assert_equal(check['status'], 'QUEUED')
    end
  end
end
