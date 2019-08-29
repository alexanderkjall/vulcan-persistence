require 'test_helper'
require 'aws-sdk-rails'
require 'json'

class ChecksCreateEnqueueJobTest < ActiveJob::TestCase
  setup do
    @scan03 = scans(:scan03)
  end

  test 'checks are created and enqeueued' do
    # Stub sqs interactions
    sqs = Aws::SQS::Client.new(region: Rails.application.config.region, stub_responses: true)
    Aws.config[:sqs] = {
        stub_responses: {
          get_queue_url: { queue_url: 'http://localhost/dummy' },
          send_message: { message_id: 'aa' }
        }
    }
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
