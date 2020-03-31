ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

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
