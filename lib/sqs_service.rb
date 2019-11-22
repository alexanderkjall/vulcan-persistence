require 'net/http'
require 'aws-sdk-rails'
require 'json'

class SQSService
  def initialize(sqs)
    @sqs = sqs
  end

  def enqueue(check, start_time)
    resp = @sqs.get_queue_url({
      queue_name: check.queue_name,
    })

    check_message = {
      "check_id" => check.id,
      "target" => check.target,
      "image" => check.checktype.image,
      "timeout" => check.checktype.timeout,
      "options" => check.options,
      "required_vars" => check.required_vars,
      "scan_id" => check.scan_id,
      "start_time" => start_time
    }

    resp = @sqs.send_message({
      queue_url: resp.queue_url,
      message_body: check_message.to_json,
    })
  end
end
