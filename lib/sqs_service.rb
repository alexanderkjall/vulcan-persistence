require 'net/http'
require 'aws-sdk-rails'
require 'json'

class SQSService
  def initialize(sqs)
    @sqs = sqs
  end

  def enqueue(check, start_time)
    Rails.logger.debug "SQSService: Start enqueuing message"
    resp = @sqs.get_queue_url({
      queue_name: check.queue_name,
    })
    if check.scan_id
      scan = Scan.find(check.scan_id)
    end
    metadata = ScansHelper.get_metadata(scan)
    Rails.logger.debug "SQSService: Target queue #{resp.queue_url}"
    check_message = {
      "check_id" => check.id,
      "target" => check.target,
      "image" => check.checktype.image,
      "timeout" => check.checktype.timeout,
      "options" => check.options,
      "required_vars" => check.required_vars,
      "scan_id" => check.scan_id,
      "metadata" => metadata,
      "start_time" => start_time
    }

    resp = @sqs.send_message({
      queue_url: resp.queue_url,
      message_body: check_message.to_json,
    })
    Rails.logger.debug "SQSService: Message #{check.id} enqueued successfully"
  end
end
