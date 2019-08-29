require 'net/http'
require 'aws-sdk-rails'
require 'json'

class SNSService
  def initialize(sns)
    @sns = sns
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
    # Right now we are only publishing to SNS Check changes.
    # If we plan to publish different object than Checks we should
    # should create a switch case and provide custom message_attributes
    # depending on the message (object) that we are publishing.
    resp = @sns.publish({
        :target_arn => sns_topic_arn,
        :message => message,
        :subject => object_type,
        :message_attributes => {
          "status" => {
            :data_type    => "String",
            :string_value => object.status.to_s
          },
          "checktype_name" => {
            :data_type    => "String",
            :string_value => object.checktype_name.to_s
          },
        }
      })
  end
end
