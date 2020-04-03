Rails.application.config.stream_channel = ENV.fetch('STREAM_CHANNEL')
Rails.application.config.scans_bucket = ENV.fetch('SCANS_BUCKET')
Rails.application.config.scan_processor_buffer = ENV.fetch('SCAN_PROCESSOR_BUFFER_SIZE_MB')
Rails.application.config.check_queue_sns = ENV['CHECK_QUEUE_SNS'] || false
Rails.application.config.sns_topic_arn = ENV.fetch('SNS_TOPIC_ARN')
Rails.application.config.nessus_check_queue = ENV['NESSUS_CHECK_QUEUE'] || "default"
