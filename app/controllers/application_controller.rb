class ApplicationController < ActionController::API
  include ActionController::Serialization
  before_action :check_content_type
  after_action  :push_response_metrics, if: -> { Rails.application.config.metrics }
  around_action :push_duration_metrics, if: -> { Rails.application.config.metrics }

  private

  def check_content_type
    if request.content_length > 0 && request.content_type != "application/json" && request.content_type != "multipart/form-data"
      Rails.logger.error "content-type error in request #{request.inspect}"
      render :json =>
      { :error => "Unsupported Media Type"},
        status: :unsupported_media_type
    end
  end

  def push_response_metrics
    if exclude_from_metrics(controller_name)
      return
    end
    if is_failed
      metic_name = "request.failed"
      Metrics.increment(metic_name, metric_tags)
    end
    # Metrics per status code
    metic_name = "request.total"
    Metrics.increment(metic_name, metric_tags)
  end

  def push_duration_metrics
    if exclude_from_metrics(controller_name)
      return
    end
    unless is_failed
      start = Time.now
      yield
      duration = Time.now - start
      metic_name = "request.duration"
      Metrics.histogram(metic_name, duration, metric_tags)
    end
  end

  def metric_tags
    tags = []
    begin
      tags = tags + ["entity:#{controller_name}"]
    rescue
      tags = tags + ["entity:unknown"]
    end
    begin
      tags = tags + ["action:#{action_name}"]
    rescue
      tags = tags + ["action:unknown"]
    end
    begin
      tags = tags + ["method:#{request.method.downcase}"]
    rescue
      tags = tags + ["method:unknown"]
    end
    begin
      tags = tags + ["status:#{status}"]
    rescue
      tags = tags + ["status:unknown"]
    end
    return tags
  end

  def is_failed
    begin
      if status < 400
        return false
      end
      return true
    rescue
      return true
    end
  end

  def exclude_from_metrics(controller)
    s = Set.new(
      [
        "healthchecks",
      ]
    )
    return s.include?(controller)
  end
end
