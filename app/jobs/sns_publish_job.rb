class SNSPublishJob < ApplicationJob
  queue_as :default

  @@sns_service = SNSService.new(Rails.application.config.sns_client)

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
