module Api::V1
  class ChecktypeSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    attributes :id, :name, :description, :timeout, :enabled, :options, :image, :assets, :queue_name

    attribute :links do
      { self: v1_checktype_path(object.id) }
    end
  end
end
