class Metrics
  def self.count(metric_name, metric_value, metric_tags)
    begin
      Rails.application.config.statsd.count(
        metric_name,
        metric_value,
        tags: Rails.application.config.metric_tags + metric_tags
      )
      Rails.logger.debug "pushed count metric [#{metric_name}] with tags [#{metric_tags}]"
    rescue
      Rails.logger.warn "error pushing count metric [#{metric_name}] with tags [#{metric_tags}]"
    end
  end

  def self.increment(metric_name, metric_tags)
    begin
      Rails.application.config.statsd.increment(
        metric_name,
        tags: Rails.application.config.metric_tags + metric_tags
      )
      Rails.logger.debug "pushed increment metric [#{metric_name}] with tags [#{metric_tags}]"
    rescue
      Rails.logger.warn "error pushing increment metric [#{metric_name}] with tags [#{metric_tags}]"
    end
  end

  def self.histogram(metric_name, value, metric_tags)
    begin
      Rails.application.config.statsd.histogram(
        metric_name,
        value,
        tags: Rails.application.config.metric_tags + metric_tags
      )
      Rails.logger.debug "pushed histogram metric [#{metric_name}] with tags [#{metric_tags}]"
    rescue
      Rails.logger.warn "error pushing histogram metric [#{metric_name}] with tags [#{metric_tags}]"
    end
  end
end
