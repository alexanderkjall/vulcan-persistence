ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov
SimpleCov.start

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/minitest'
require 'minitest/autorun'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  ActiveSupport::TestCase.test_order= :sorted
  Rails.application.config.active_job.queue_adapter = :inline
  WebMock.disable_net_connect!(allow_localhost: true)

  def stub_sqs
    sqs = Aws::SQS::Client.new(region: Rails.application.config.region, stub_responses: true)
    Aws.config[:sqs] = {
      stub_responses: {
        get_queue_url: { queue_url: 'http://localhost/dummy' },
        send_message: { message_id: "fake_id" }
      }
    }
  end

  def stub_sns
    sns = Aws::SNS::Client.new(region: Rails.application.config.region, stub_responses: true)
    Aws.config[:sns] = {
      stub_responses: {
        publish: { }
      }
    }
    WebMock.stub_request(:post, "https://sns.eu-west-1.amazonaws.com/").
      to_return(status: 200, body: "stubbed response", headers: {})
  end
end

def hash_deep_diff(a,b)
  (a.keys | b.keys).inject({}) do |diff, k|
    if a[k] != b[k]
      if a[k].respond_to?(:deep_diff) && b[k].respond_to?(:deep_diff)
        diff[k] = a[k].deep_diff(b[k])
      else
        diff[k] = [a[k], b[k]]
      end
    end
    diff
  end
end

def delete_fields(from,fields)
  fields.each {|f|from.delete(f)}
end
