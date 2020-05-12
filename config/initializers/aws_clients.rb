require 'aws-sdk-rails'

region = ENV['REGION'] || ""
s3_endpoint = ENV['AWS_S3_ENDPOINT'] || ""
sns_endpoint = ENV['AWS_SNS_ENDPOINT'] || ""
sqs_endpoint = ENV['AWS_SQS_ENDPOINT'] || ""

Aws.config.update({
  retry_backoff: lambda { |c| sleep(3) }
})

if region != ""
  Aws.config.update({
    region: region,
  })
end

sqs_options = {}
sns_options = {}
s3_options  = {}

if ENV['RAILS_ENV'] == "test"
  WebMock.disable_net_connect!(allow_localhost: true)
  sqs_options = {
    :stub_responses  => {
      :get_queue_url => { queue_url:  'http://localhost/dummy' },
      :send_message  => { message_id: 'fake_message_id' },
    }
  }

  sns_options = {
    :stub_responses => {
      :publish      => {},
    }
  }

  s3_options = {
    :stub_responses => true,
  }
end

if sqs_endpoint != ""
  sqs_options = {
    :endpoint  => sqs_endpoint,
    :log_level => "debug",
  }
end

if sns_endpoint != ""
  sns_options = {
    :endpoint  => sns_endpoint,
    :log_level => "debug",
  }
end

if s3_endpoint != ""
  s3_options = {
    :endpoint         => s3_endpoint,
    :force_path_style => true,
    :log_level        => "debug",
  }
end

Rails.logger.debug "SQS Client Options: #{sqs_options}"
Rails.application.config.sqs_client = Aws::SQS::Client.new(sqs_options)
Rails.logger.debug "SNS Client Options: #{sns_options}"
Rails.application.config.sns_client = Aws::SNS::Client.new(sns_options)
Rails.logger.debug "S3 Client Options: #{s3_options}"
Rails.application.config.s3_client  = Aws::S3::Client.new(s3_options)
