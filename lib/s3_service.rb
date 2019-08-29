require 'net/http'
require 'aws-sdk-rails'
require 'json'
class S3Service
  def initialize(bucket)
    @bucket = bucket
  end

  def upload(data, filename)
    object = @bucket.object(filename)
    object.upload_file(data.tempfile)
  end

  def get_stream(filename)
    @bucket.client.get_object(bucket: @bucket.name, key: filename)
  end
end
