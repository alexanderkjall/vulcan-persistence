class SNSPublishJob < ApplicationJob
  queue_as :default

  if Rails.application.config.sns_topic_endpoint == ""
    client = Aws::SNS::Client.new(region: Rails.application.config.region)
  else
    client = Aws::SNS::Client.new(
      region: Rails.application.config.region,
      endpoint: Rails.application.config.sns_topic_endpoint,
    )
  end

  @@sns_service = SNSService.new(client)

  def self.set_sns(sns_client)
    @@sns_service = SNService.new(sns_client)
    self
  end

  def perform(object)
    begin
      @@sns_service.publish_message(object)
    rescue => e
      # TODO: check what happens if we log after the save, and save raises
      # an exception.
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
    end
  end
end
