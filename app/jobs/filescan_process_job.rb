class FilescanProcessJob < ApplicationJob
  queue_as :default
  @@s3_bucket =  Aws::S3::Resource.new(client: Rails.application.config.s3_client).bucket(Rails.application.config.scans_bucket)
  @@s3_service = S3Service.new(@@s3_bucket)
  @@chunk_size = Rails.application.config.scan_processor_buffer.to_i*1024

  def perform(scan, scan_start_time,queue_now = false)
    @scan_id = scan
    @queue_now = queue_now
    scan_file = scan + '.json'
    @scan_start_time = scan_start_time
    Rails.logger.info "Processing scan in file: #{scan_file}"
    stream = @@s3_service.get_stream(scan_file)
    processor = ScanProcessor.new(Rails.logger, method(:check_parsed))
    stream.body.each(nil, @@chunk_size) do |chunk|
      processor.receive_data(chunk)
    end
  rescue Exception => e
    Rails.logger.error 'processing scan ' + e.inspect
    raise e
  end

  def check_parsed(check)
    created_check = ChecksHelper.create_check(check, @scan_id)
    if created_check.nil?
      Rails.logger.error "error creating check with params: #{check.inspect} for scan_id #{@scan_id}"
    else
      if @queue_now
        ChecksEnqueueJob.perform_now([created_check], @scan_start_time)
      else
        ChecksEnqueueJob.perform_later([created_check], @scan_start_time)
      end
     end
  rescue Exception => e
    Rails.logger.error 'creating check ' + e.inspect
    raise e
  end
end
