require 'aws-sdk-rails'

rails_env = ENV['RAILS_ENV']
region = ENV['REGION'] || ""
endpoint = ENV['AWS_ENDPOINT'] || ""

if region != ""
  Aws.config.update({
    region: region,
  })
end

if endpoint != ""
  Aws.config.update({
    endpoint: endpoint,
    credentials: Aws::Credentials.new('fake_access_key', 'fake_secret_key'),
    log_level: "debug",
  })
end

if rails_env == "test"
  WebMock.disable_net_connect!(allow_localhost: true)
  # SQS Client
  Rails.application.config.sqs_client = Aws::SQS::Client.new(
    stub_responses: true,
  )
  Rails.application.config.sqs_client.stub_responses(
    :get_queue_url, { queue_url: 'http://localhost/dummy' },
  )
  Rails.application.config.sqs_client.stub_responses(
    :send_message, { message_id: "fake_message_id" },
  )
  # SNS Client
  Rails.application.config.sns_client = Aws::SNS::Client.new(
    stub_responses: true,
  )
  Rails.application.config.sns_client.stub_responses(
    :publish, {},
  )
  # S3 Client
  Rails.application.config.s3_client = Aws::S3::Client.new(
    stub_responses: true,
  )
else
  Rails.application.config.sqs_client = Aws::SQS::Client.new()
  Rails.application.config.sns_client = Aws::SNS::Client.new()
  Rails.application.config.s3_client = Aws::S3::Client.new()
end
