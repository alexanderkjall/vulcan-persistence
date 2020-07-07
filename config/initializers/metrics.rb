Rails.application.config.metrics = ENV['DOGSTATSD_ENABLED'] || false
metrics_host = ENV['DOGSTATSD_HOST'] || "localhost"
metrics_port = ENV['DOGSTATSD_PORT'] || 8125

if Rails.application.config.metrics
  require 'datadog/statsd'
  Rails.application.config.metrics = true
  Rails.application.config.statsd = Datadog::Statsd.new(metrics_host, metrics_port, :namespace => 'vulcan')
  Rails.application.config.metric_tags = ['component:persistence']
end
