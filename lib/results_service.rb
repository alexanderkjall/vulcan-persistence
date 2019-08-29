require 'net/http'
require 'aws-sdk-rails'
require 'base64'

class ResultsService
  def initialize(region, bucket, url)
    @s3 = Aws::S3::Resource.new(region: region)
    @bucket = bucket
    @url = url
  end

  def save_report(jobqueue_id, check_id, result)
    # TODO: change vulcan-api to serve results from jobqueue_ids
    # key = File.join(jobqueue_id, check_id, 'report')
    key = File.join(check_id, 'report')
    obj = @s3.bucket(@bucket).object("#{key}.json")

    # string data
    decoded = Base64.decode64(result)
    obj.put(body: decoded, content_type: "application/json")

    File.join(@url, key)
  end

  def save_raw(jobqueue_id, check_id, result="")
    # TODO: change vulcan-api to serve results from jobqueue_ids
    # key = File.join(jobqueue_id, check_id, 'raw')
    key = File.join(check_id, 'raw')
    obj = @s3.bucket(@bucket).object("#{key}.txt")

    # string data
    unless result.nil?
      decoded = Base64.decode64(result)
      obj.put(body: decoded, content_type: "text/plain")

      File.join(@url, key)
    end
  end
end
