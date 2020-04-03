class ChecksEnqueueJob < ApplicationJob
  queue_as :default

  @@sqs_service = SQSService.new(Rails.application.config.sqs_client)
  @@sns_service = SNSService.new(Rails.application.config.sns_client)

  def self.set_sqs(sqs_client)
    @@sqs_service = SQSService.new(sqs_client)
    self
  end

  def perform(checks, start_time)
    checks.each do |check|
      begin
        if ScansHelper.is_aborted(check.scan_id)
          check.abort!
          Rails.logger.info "Scan #{check.scan_id} has been aborted. Check #{check.id} aborted."
          return
        end
        if Rails.application.config.check_queue_sns
          @@sns_service.publish_check(check, start_time)
        else
          @@sqs_service.enqueue(check, start_time)
        end
        check.status = "QUEUED"
        check.save
      rescue => e
        # TODO: check what happens if we log after the save, and save raises
        # an exception.
        Rails.logger.error e.message
        Rails.logger.error e.backtrace.join("\n")

        check.status = "FAILED"
        check.progress = 1.0
        check.save
      end
    end
  end
end
