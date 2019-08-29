class ApplicationController < ActionController::API
  include ActionController::Serialization
  before_action :check_content_type

  private

  def check_content_type
    if request.content_length > 0 && request.content_type != "application/json" && request.content_type != "multipart/form-data"
      Rails.logger.error "content-type error in request #{request.inspect}"
      render :json =>
      { :error => "Unsupported Media Type"},
        status: :unsupported_media_type
    end
  end

end
