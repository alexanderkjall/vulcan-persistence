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

    resp = @sqs.send_message({
      queue_url: resp.queue_url,
      message_body: ChecksHelper.check_message(check, start_time),
    })
  end
end
