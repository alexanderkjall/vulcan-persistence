require 'test_helper'
require 'aws-sdk-rails'
require 'json'

class SNSPublishJobTest < ActiveJob::TestCase
  setup do
    stub_sns
    stub_sqs
    @check03 = checks(:check03)
  end

  test 'check modifications are published to sns' do
    SNSPublishJob.perform_now(@scan03)
  end
end
