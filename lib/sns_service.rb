require 'net/http'
require 'aws-sdk-rails'
require 'json'

class SNSService
  def initialize(sns)
    @sns = sns
  end

  def publish_check(check, start_time, sns_topic_arn = Rails.application.config.sns_topic_arn)
    tag = check.tag || "UNKNOWN"
    checktype = check.checktype.name || "UNKNOWN"
    queue_filter = checktype.start_with?("vulcan-nessus") ? "TENABLE" : "GENERIC"
    resp = @sns.publish({
        :topic_arn => sns_topic_arn,
        :message => ChecksHelper.check_message(check, start_time),
        :subject => "agent_check_message",
        :message_attributes => {
          "queue" => {
            :data_type    => "String",
            :string_value => queue_filter,
          },
          "team" => {
            :data_type    => "String",
            :string_value => tag,
          },
          "checktype" => {
            :data_type    => "String",
            :string_value => checktype,
          },
        }
      })
  end

  def publish_message(object, sns_topic_arn = Rails.application.config.sns_topic_arn)
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

    status = object.status.to_s || "UNKNOWN"
    checktype_name = object.checktype_name.to_s || "UNKNOWN"
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
  end
end
