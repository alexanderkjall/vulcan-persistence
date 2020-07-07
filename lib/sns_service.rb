require 'net/http'
require 'aws-sdk-rails'
require 'json'

class SNSService
  def initialize(sns)
    @sns = sns
  end

  def publish_message(object, sns_topic_arn = Rails.application.config.sns_topic_arn)
    Rails.logger.debug "SNSService: Start publishing message"
    Rails.logger.debug "SNSService: Target topic #{sns_topic_arn}"
    object_type = object.class.name.demodulize
    message = object.to_json
    if object_type == "Check"
      checktype = Checktype.find(object.checktype_id)
      unless checktype.nil?
        # using Check's checktype_name virtual attribute.
        object.checktype_name = checktype.name
        message = object.to_json(methods: :checktype_name)
      end
    end
    status = "UNKNOWN"
    begin
      status = object.status.to_s
    rescue
      Rails.logger.warn "SNSService: Can't get status for #{object}"
    end
    checktype_name = "UNKNOWN"
    begin
      checktype_name = object.checktype_name.to_s
    rescue
      Rails.logger.warn "SNSService: Can't get checktype name for #{object}"
    end
    # Right now we are only publishing to SNS Check changes.
    # If we plan to publish different object than Checks we should
    # should create a switch case and provide custom message_attributes
    # depending on the message (object) that we are publishing.
    resp = @sns.publish({
        :topic_arn => sns_topic_arn,
        :message => message,
        :subject => object_type,
        :message_attributes => {
          "status" => {
            :data_type    => "String",
            :string_value => status,
          },
          "checktype_name" => {
            :data_type    => "String",
            :string_value => checktype_name,
          },
        }
      })
    Rails.logger.debug "SNSService: Message #{object_type} published successfully"
  end
end
