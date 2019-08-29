module Api::V1
  class JobqueueSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    attributes :id, :name, :arn, :description, :default

    attribute :links do
      { self: v1_jobqueue_path(object.id) }
    end
  end
end
