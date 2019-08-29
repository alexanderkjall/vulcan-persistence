require 'test_helper'
require 'aws-sdk-rails'
require 'json'
class ChecksCreateEnqueueJobTest < ActiveJob::TestCase
  setup do
    stub_sns
    @scan = scans(:scan04)
  end
  test 'checks are created and enqueued by streanming a S3 file' do
    stub_sqs
    checks_params = { scan: { checks: [{ check: { checktype_name: 'tls', target: 'localhost', options: '     ' } }, { check: { checktype_name: 'tls', target: 'www.example.com', options: '     ' } }] } }
    # stub s3
    Aws.config[:s3] = { stub_responses: { get_object: { body: checks_params.to_json.to_s } } }
    FilescanProcessJob.perform_now(@scan.id, @scan.created_at.to_s,true)
    checks = Check.where(deleted_at: nil, scan_id: @scan.id)
    checks.each do |check|
      assert_equal(check['status'],'QUEUED')
    end
  end
end
