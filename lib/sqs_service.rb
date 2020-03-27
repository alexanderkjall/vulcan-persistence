require 'net/http'
require 'aws-sdk-rails'
require 'json'
require 'uri'

def valid_url(url)
  uri = URI.parse(url)
  uri.is_a?(URI::HTTP) && !uri.host.nil?
rescue URI::InvalidURIError
  false
end

class SQSService
  def initialize(sqs)
    @sqs = sqs
  end

  def enqueue(check, start_time)
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

    # Obtain queue url.
    queue_url = ""
    if valid_url(check.queue_name)
      queue_url = check.queue_name
    else
      begin
        resp = @sqs.get_queue_url({
          queue_name: check.queue_name,
        })
        queue_url = resp.queue_url
      rescue => e
        Rails.logger.error "error obtaining queue url for check: #{check.id} for queue #{check.queue_name}"
        Rails.logger.error e.message
        return
      end
    end

    # Publish check to queue.
    begin
      resp = @sqs.send_message({
        queue_url: queue_url,
        message_body: check_message.to_json,
      })
    rescue => e
      Rails.logger.error "error queueing check: #{check.id} to queue #{queue_url}"
      Rails.logger.error e.message
      return
    end
  end
end
