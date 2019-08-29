require 'securerandom'

class Filescan
  @@s3_client = Aws::S3::Client.new(region: Rails.application.config.region)
  @@s3_bucket =  Aws::S3::Resource.new(client: @@s3_client).bucket(Rails.application.config.scans_bucket)
  @@s3_service = S3Service.new(@@s3_bucket)
  def self.save_scan(id, params)
    name = id.to_s + ".json"
    @@s3_service.upload(params['upload'], name)
  end
  # This is needed in to avoid the model to be persited to db by rails. 
  def persisted?
    false
  end

end